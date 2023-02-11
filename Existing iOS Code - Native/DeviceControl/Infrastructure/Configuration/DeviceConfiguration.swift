//
//  DeviceConfiguration.swift
//  DeviceControl
//
//  Created by Davis Allie on 21/7/21.
//

import CoreBluetooth
import Foundation

public struct DeviceConfiguration {
    
    public var defaultName: String
    public var defaultWifiPassword: String
    public var defaultBluetoothPin: Int
    
    var serviceUUID: CBUUID
    
}
