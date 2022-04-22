//
//  HomeView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 09/04/2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = ViewModel()
    
    init(devices: [Device]? = nil) {
        if let devices = devices {
            viewModel.devicesLoadingState = .loaded(devices: devices)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch(viewModel.devicesLoadingState) {
                case .loading:
                    ProgressView().task {
                        await viewModel.loadDevices()
                    }
                case .hasError:
                    Text("An error has occured fetching your devices").foregroundColor(Color.red)
                case .loaded(let devices):
                    DevicesView(devices: devices)
                }
                
            }.toolbar {
                NavigationLink(destination: ScanDevicesView()) {
                    Text("+")
                }
            }
        }
    }
}

extension HomeView {
    enum DevicesLoadingState {
        case loading
        case loaded(devices: [Device])
        case hasError
    }
    
    class ViewModel: ObservableObject {
        @Published var devicesLoadingState: DevicesLoadingState = .loading
        
        func loadDevices() async {
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
