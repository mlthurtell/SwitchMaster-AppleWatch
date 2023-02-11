//
//  CharacteristicConfiguration+SwitchMaster.swift
//  DeviceControl
//
//  Created by Davis Allie on 21/7/21.
//

import Foundation

extension CharacteristicConfiguration {
    
    public static let switchMaster = CharacteristicConfiguration(
        readUUID: .init(string: "2ff2caa4-7932-44c6-b73a-a7cfb897d43c"),
        writeUUID: .init(string: "2ff2caa4-7932-44c6-b73a-a7cfb897d43d"),
        configUUID: .init(string: "2ff2caa4-7932-44c6-b73a-a7cfb897d43e")
    )
    
}
