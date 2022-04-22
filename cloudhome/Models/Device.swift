//
//  Device.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 13/04/2022.
//

class Device {
    let id: String
    let name: String
    let typeCode: Int
    
    init(id: String, name: String, typeCode: Int) {
        self.id = id
        self.name = name
        self.typeCode = typeCode
    }
}

class SwitchAndSocket: Device {
    let switchState: Bool
    let socketState: Bool
    
    init(id: String, name: String, switchState: Bool, socketState: Bool) {
        self.switchState = switchState
        self.socketState = socketState
        super.init(id: id, name: name, typeCode: 0)
    }
}
