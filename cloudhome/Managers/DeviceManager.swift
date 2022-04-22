//
//  DeviceManager.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 08/04/2022.
//

import NetworkExtension
import OSLog

struct DeviceMethod: Decodable {
    let name: String
    let label: String
}

struct DeviceConfig: Decodable {
    let methods: [DeviceMethod]
}

struct DeviceInfo: Decodable {
    let name: String
    let description: String
    let config: DeviceConfig
}

class DeviceManager {
    static var shared = DeviceManager()
    
    private let ip = "192.168.4.1"
    
    struct URLParsingError: Error {}
    
    private struct DeviceInfoResult: Decodable {
        let typeCode: Int
        let version: Double
        let deviceId: String
    }
    
    private let logger = Logger()
    
    struct RPCError: Error {}
    
    private func rpc<T: Decodable>(_ method: String, _ args: [String: Any]? = nil) async throws -> T {
        if let url = URL(string: "http://\(ip)/rpc/\(method)") {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            if let args = args {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: args as Any)
            }
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if Double((response as! HTTPURLResponse).statusCode) / 100.0 != 2.0 {
                throw RPCError()
            }
            logger.info("received result: \(String(data: data, encoding: .utf8)!, privacy: .public)")
            return try JSONDecoder().decode(T.self, from: data)
        }
        
        throw URLParsingError()
    }
    
    private func rpc_with_retry<T: Decodable>(_ method: String, _ args: [String: Any]? = nil) async throws -> T {
        do {
            let res: T = try await rpc(method, args)
            return res
        } catch {
            try await Task.sleep(nanoseconds: 500 * 1000)
            let res: T = try await rpc(method, args)
            return res
        }
    }
    
    struct ReadingDevicesJsonError: Error {}
    struct ParsingDevicesJsonError: Error {}
    struct DeviceNotFoundError: Error {}
    
    func getDeviceInfo() async throws -> (String, DeviceInfo) {
        logger.info("Getting device info..")
        let deviceInfoResult: DeviceInfoResult = try await rpc_with_retry("Info.Get")
        
        guard let bundlePath = Bundle.main.path(forResource: "devices", ofType: "json") else {
            throw ReadingDevicesJsonError()
        }
        guard let devicesJson = try String(contentsOfFile: bundlePath).data(using: .utf8) else {
            throw ParsingDevicesJsonError()
        }
        let devices = try JSONDecoder().decode([String: DeviceInfo].self, from: devicesJson)
        guard let device = devices[String(deviceInfoResult.typeCode)] else {
            throw DeviceNotFoundError()
        }
        return (deviceInfoResult.deviceId, device)
    }
    
    struct ConfigSetResult: Decodable {
        let saved: Bool
    }
    
    struct UserIdSetResult: Decodable {
        let success: Bool
    }
    
    func configureDevice(ssid: String, password: String) async throws {
        let uid = AuthManager.shared.user!.uid
        let _: ConfigSetResult = try await rpc("Config.Set", ["config": ["wifi.sta.ssid": ssid, "wifi.sta.pass": password, "wifi.sta.enable": true, "cloudhome.uid": uid]])
        let _: UserIdSetResult = try await rpc("Init", ["uid": uid])
        let _: ConfigSetResult = try await rpc("Config.Save", ["reboot": true])
    }
}
