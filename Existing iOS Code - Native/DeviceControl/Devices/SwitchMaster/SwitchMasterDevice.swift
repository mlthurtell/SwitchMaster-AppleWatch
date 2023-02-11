//
//  SwitchMasterDevice.swift
//  DeviceControl
//
//  Created by Davis Allie on 28/6/21.
//

import CoreBluetooth
import Foundation

struct SwitchMasterDeviceSnapshot: DeviceProtocol {
    
    typealias StatusBufferType = StatusByteBuffer
    typealias ControlBufferType = ControlByteBuffer
    typealias ConfigBufferType = ConfigurationByteBuffer
    
    var macAddress: [Int] = []
    var batteryVoltage = Measurement(value: 0.0, unit: UnitElectricPotentialDifference.volts)
    var totalCurrentDraw = Measurement(value: 0.0, unit: UnitElectricCurrent.amperes)
    
    var outputStates = Array(repeating: false, count: 10)
    
    mutating func applyStatusData(buffer: StatusByteBuffer) {
        macAddress = buffer.macAddress.map { Int($0) }
        batteryVoltage = Measurement(value: Double(buffer.voltage) / 100.0, unit: UnitElectricPotentialDifference.volts)
        totalCurrentDraw = Measurement(value: Double(buffer.current) / 100.0, unit: UnitElectricCurrent.amperes)
        outputStates = buffer.outputs
        
        print(buffer.voltage)
        print(buffer.outputs)
        print(outputStates)
    }
    
    func createControlBuffer() throws -> ControlByteBuffer {
        ControlByteBuffer(macAddress: Data(macAddress.map(UInt8.init)), outputs: outputStates)
    }
    
    static func dummyControlBuffer() -> ControlByteBuffer {
        ControlByteBuffer(macAddress: Data(Array(repeating: UInt8(0), count: 6)), outputs: Array(repeating: false, count: 10))
    }
    
}
