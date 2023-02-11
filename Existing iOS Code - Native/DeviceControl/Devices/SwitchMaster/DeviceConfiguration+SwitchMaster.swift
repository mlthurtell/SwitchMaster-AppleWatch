//
//  DeviceConfiguration+SwitchMaster.swift
//  DeviceControl
//
//  Created by Davis Allie on 21/7/21.
//

import Foundation

extension DeviceConfiguration {
    
    public static var switchMaster = DeviceConfiguration(
        defaultName: "MLT_Industries",
        defaultWifiPassword: "ControlMe",
        defaultBluetoothPin: 123456,
        serviceUUID: .init(string: "42574065-18ed-41e9-a723-b85ac1d74a42")
    )
    
}
