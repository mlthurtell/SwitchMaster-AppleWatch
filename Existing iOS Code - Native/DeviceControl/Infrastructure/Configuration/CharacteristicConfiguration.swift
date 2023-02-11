//
//  CharacteristicConfiguration.swift
//  DeviceControl
//
//  Created by Davis Allie on 21/7/21.
//

import CoreBluetooth
import Foundation

struct CharacteristicConfiguration {
    
    var readUUID: CBUUID
    var writeUUID: CBUUID
    var configUUID: CBUUID
    
}
