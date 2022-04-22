//
//  NetworkManager.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 31/03/2022.
//

import Foundation
import NetworkExtension

class NetworkManager {
    static var shared = NetworkManager()
    
    private let config = NEHotspotConfiguration(ssidPrefix: "Mongoose_", passphrase: "Mongoose", isWEP: false)
    private var mongooseSsid: String? = nil
    
    init() {
        config.joinOnce = true
    }
    
    func joinDeviceNetwork() async throws {
        try await NEHotspotConfigurationManager.shared.apply(config)
        mongooseSsid = await NEHotspotNetwork.fetchCurrent()?.ssid
    }
    
    func rejoinPreviousNetwork(ssid: String, password: String) async throws {
        if let mongooseSsid = mongooseSsid {
            NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: mongooseSsid)
        }
        let newConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        try await NEHotspotConfigurationManager.shared.apply(newConfig)
    }
}
