//
//  DevicesView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 13/04/2022.
//

import SwiftUI

struct DevicesView: View {
    let devices: [Device]
    
    init(devices: [Device]) {
        self.devices = devices
    }
    
    var body: some View {
        if devices.count > 0 {
            List (devices, id: \.id){ device in
                if device.typeCode == 0 {
                    
                } else {
                    Text("Unknown device")
                }
            }
        } else {
            NavigationLink(destination: ScanDevicesView()) {
                Text("No devices found, tap to add a device")
            }.frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DevicesView(devices: [])
            DevicesView(devices: [Device(id: "0", name: "SwitchAndSocket", typeCode: 0)])
        }
    }
}
