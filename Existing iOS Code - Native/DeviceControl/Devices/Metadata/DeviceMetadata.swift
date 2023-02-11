//
//  DeviceMetadata.swift
//  DeviceControl
//
//  Created by Davis Allie on 30/3/2022.
//

import Foundation

public struct DeviceMetadata: Codable, Identifiable {
    
    public enum ControllerType: Int, Codable, CaseIterable {
        case switchMaster, switchMasterMaxi
        
        public var name: String {
            switch self {
            case .switchMaster:
                return "SwitchMaster"
            case .switchMasterMaxi:
                return "SwitchMaster MAXI"
            }
        }
    }
    
    public var nickname: String
    public var bluetoothIdentifier: UUID
    
    public var macAddress: [Int]
    public var bluetoothPIN: String
    public var wifiSSID: String
    public var wifiPassword: String
    
    public var type: ControllerType
    public var voltageOffset: Double
    public var outputs: [DeviceOutput]
    
    public var id: UUID {
        bluetoothIdentifier
    }
    
    public init(type: ControllerType, nickname: String, bluetoothIdentifier: UUID, macAddress: [Int], bluetoothPIN: String, wifiSSID: String, wifiPassword: String) {
        self.nickname = nickname
        self.bluetoothIdentifier = bluetoothIdentifier
        self.macAddress = macAddress
        self.bluetoothPIN = bluetoothPIN
        self.wifiSSID = wifiSSID
        self.wifiPassword = wifiPassword
        
        self.type = type
        self.voltageOffset = 0.0
        
        switch type {
        case .switchMaster:
            outputs = .init(repeating: .init(), count: 5)
        case .switchMasterMaxi:
            outputs = .init(repeating: .init(), count: 10)
        }
    }
    
}
