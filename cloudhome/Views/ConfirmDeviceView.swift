//
//  ConfirmDeviceView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 08/04/2022.
//

import SwiftUI

struct ConfirmDeviceView: View {
    @StateObject var viewModel = ViewModel()
    @State var goToNextView = false
    
    var body: some View {
        NavigationView{
            switch viewModel.viewState {
            case .loading:
                ProgressView().task {
                    await viewModel.readDeviceInfo()
                }
            case .hasError:
                Text("Something wrong occured").foregroundColor(Color.red)
            case .hasDeviceInfo(let (deviceId, deviceInfo)):
                VStack {
                    Text("Found device:")
                    Text(deviceInfo.name)
                    Text(deviceInfo.description)
                    Button("Connect device to wifi") {
                        goToNextView = true
                    }
                    
                    NavigationLink(destination: SelectWiFiView(deviceId: deviceId).navigationBarHidden(true), isActive: $goToNextView) {
                        EmptyView()
                    }
                }
            }
        }
    }
}

extension ConfirmDeviceView {
    enum ViewState {
        case loading
        case hasError
        case hasDeviceInfo((String, DeviceInfo))
    }
    
    class ViewModel: ObservableObject {
        @Published var viewState: ViewState = .loading
        
        @MainActor
        func readDeviceInfo() async {
            do {
                let (deviceId, deviceInfo) = try await DeviceManager.shared.getDeviceInfo()
                
                viewState = .hasDeviceInfo((deviceId, deviceInfo))
            } catch let error {
                viewState = .hasError
                print(error)
            }
        }
    }
}

struct ConfirmDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmDeviceView()
    }
}
