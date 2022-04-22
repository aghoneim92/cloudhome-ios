//
//  SelectWiFiView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 31/03/2022.
//

import SwiftUI
import NetworkExtension
import OSLog

struct SelectWiFiView: View {
    @StateObject var viewModel = ViewModel()
    var deviceId: String
    @State var showPasswordEntry = false
    @State var selectedSsid = ""
    @State var wifiPassword = ""
    @State var goToNextView = false
    
    init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    func configureDevice() {
        Task {
            await viewModel.configureDevice(deviceId: deviceId, ssid: selectedSsid, password: wifiPassword)
            goToNextView = true
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.loading {
                    Text("Scanning wifi networks..")
                    ProgressView().task {
                        await viewModel.getDeviceInfo()
                    }
                } else if viewModel.wifiScanResult.isEmpty {
                    Text("No wifi networks found").padding()
                    Button("Scan again") {
                        Task {
                            await viewModel.getDeviceInfo()
                        }
                    }
                } else {
                    Text("Please select a wifi network")
                    List (viewModel.wifiScanResult, id: \.ssid){ result in
                        Button(result.ssid) {
                            showPasswordEntry = true
                            selectedSsid = result.ssid
                        }
                    }.scaledToFit()
                    if showPasswordEntry {
                        TextField("xxxxxxxx", text: $wifiPassword).onSubmit {
                            configureDevice()
                        }
                        
                        Button("Ok") {
                            configureDevice()
                        }
                    }
                    if viewModel.hasError {
                        Text("An error occured").foregroundColor(Color.red)
                    }
                }
            }.navigationBarHidden(true)
        }
    }
}

struct WifiScanResult: Hashable, Codable {
    let ssid: String
}

extension SelectWiFiView {
    class ViewModel: ObservableObject {
        private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SelectWifiView")
        private let ip = "192.168.4.1"
        
        @Published var loading = true
        @Published var wifiScanResult: [WifiScanResult] = []
        @Published var hasError = false
        
        @MainActor
        func getDeviceInfo() async {
            hasError = false
            if let url = URL(string: "http://\(ip)/rpc/Wifi.Scan") {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let wifiScanResult = try JSONDecoder().decode([WifiScanResult].self, from: data)
                    self.wifiScanResult = wifiScanResult
                    loading = false
                } catch {
                    hasError = true
                    print(error)
                }
            }
        }
        
        @MainActor
        func configureDevice(deviceId: String, ssid: String, password: String) async {
            do {
                try await DeviceManager.shared.configureDevice(ssid: ssid, password: password)
                try await NetworkManager.shared.rejoinPreviousNetwork(ssid: ssid, password: password)
                try await DatabaseManager.shared.addDeviceToUser(deviceId)
            } catch {
                hasError = true
                logger.error("Failed to configure device: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

struct SelectWiFiView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectWiFiView(deviceId: "")
        }
    }
}
