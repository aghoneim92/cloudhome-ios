//
//  SwitchAndSocketView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 14/04/2022.
//

import SwiftUI

struct SwitchAndSocketView: View {
    let device: SwitchAndSocket
    @StateObject var viewModel = ViewModel()
    
    init(device: SwitchAndSocket) {
        self.device = device
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text(device.name).padding()
            Toggle("Switch", isOn: $viewModel.switchOn).padding()
            Toggle("Socket", isOn: $viewModel.socketOn).padding()
        }.padding()
    }
}

extension SwitchAndSocketView {
    class ViewModel: ObservableObject {
        @Published var switchOn = false
        @Published var socketOn = false
    }
}

struct SwitchAndSocketView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchAndSocketView(device: SwitchAndSocket(id: "0", name: "SwitchAndSocket", switchState: false, socketState: false))
    }
}
