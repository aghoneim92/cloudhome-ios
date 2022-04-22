//
//  ScanDevicesView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 24/03/2022.
//

import SwiftUI
import NetworkExtension
import UIKit
import Firebase

struct ScanDevicesView: View {
    @State var loading = false
    @State var hasError = false
    @State var goToNextView = false
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Button("Scan for devices") {
                    loading = true
                    Task {
                        do {
                            try await viewModel.joinDeviceNetwork()
                            
                            goToNextView = true
                        } catch (let error) {
                            print(error)
                            hasError = true
                        }
                        loading = false
                    }
                }.disabled(loading).padding()
                
                if hasError {
                    Text("An error has occured.").foregroundColor(Color.red)
                }

                if loading {
                    ProgressView()
                }

                NavigationLink(destination: ConfirmDeviceView().navigationBarHidden(true), isActive: $goToNextView) {
                    EmptyView()
                }
            }.navigationBarHidden(true)
        }
    }
}

struct GenericError: Error {}

extension ScanDevicesView {
    class ViewModel: ObservableObject {
        let locationManager = LocationManager()
        
        @MainActor
        func joinDeviceNetwork() async throws {
            if locationManager.getAuthorizationStatus() != .authorizedAlways && locationManager.getAuthorizationStatus() != .authorizedWhenInUse {
                await locationManager.requestPermissions()
                
                if locationManager.getAuthorizationStatus() != .authorizedAlways && locationManager.getAuthorizationStatus() != .authorizedWhenInUse {
                    throw GenericError()
                }
            }
            
            try await NetworkManager.shared.joinDeviceNetwork()
        }
    }
}

struct ScanDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        ScanDevicesView()
    }
}
