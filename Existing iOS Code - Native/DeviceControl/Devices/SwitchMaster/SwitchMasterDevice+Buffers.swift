//
//  SwitchMasterDevice+Buffers.swift
//  DeviceControl
//
//  Created by Davis Allie on 21/7/21.
//

import Foundation

extension SwitchMasterDeviceSnapshot {
    
    struct StatusByteBuffer: ByteBufferDecodable {
        var macAddress: Data
        var outputs: [Bool]
        var voltage: Int // steps of 10mV
        var current: Int // steps of 10mA
        
        init(byteBuffer: Data) throws {
            macAddress = Data(count: 6)
            outputs = Array(repeating: false, count: 10)
            voltage = 0
            current = 0
            
            for (i, byte) in byteBuffer.enumerated() {
                switch i {
                case 0...5: // MAC address
                    macAddress[i] = byte
                case 6: // LSB outputs
                    for b in 0 ..< 8 {
                        outputs[b] = byte & (1 << b) != 0
                    }
                case 7: // MSB outputs
                    for b in 0 ..< 2 {
                        outputs[8+b] = byte & (1 << b) != 0
                    }
                case 8: // LSB voltage
                    voltage = Int(byte)
                case 9: // MSB voltage
                    voltage += Int(byte) << 8
                case 10: // LSB current
                    current = Int(byte)
                case 11: // MSB current
                    current += Int(byte) << 8
                default:
                    fatalError()
                }
            }
        }
    }
    
    struct ControlByteBuffer: ByteBufferEncodable {
        var macAddress: Data
        var outputs: [Bool]
        
        func toByteBuffer() throws -> Data {
            var output = Data(count: 8)
            
            // In debug we don't have a MAC address
            //#if !DEBUG
            for i in 0 ..< 6 {
                output[i] = macAddress[i]
            }
            //#endif
            
            var outputBitmask: UInt8 = 0
            for i in 0 ..< 8 where outputs[i] {
                outputBitmask |= (1 << i)
            }
            output[6] = outputBitmask
            
            outputBitmask = 0
            for i in 8 ..< 10 where outputs[i] {
                outputBitmask |= (1 << (i-8))
            }
            output[7] = outputBitmask
            
            return output
        }
    }
    
    struct ConfigurationByteBuffer: ByteBufferEncodable {
        var macAddress: [Int]
        var ssid: String
        var wifiPassword: String
        var bluetoothPin: Int
        
        func toByteBuffer() throws -> Data {
            var output = Data(count: 6 + 20 + 32 + 4)
            
            if !macAddress.isEmpty {
                for i in 0 ..< 6 {
                    output[i] = UInt8(macAddress[i])
                }
            }
            
            for (i, char) in ssid.utf16.enumerated() {
                output[6+i] = UInt8(char)
            }
            
            for (i, char) in wifiPassword.utf16.enumerated() {
                output[26+i] = UInt8(char)
            }
            
            let pinArray = withUnsafeBytes(of: bluetoothPin.littleEndian, Array.init)
            for i in 0 ..< 4 {
                output[58+i] = pinArray[i]
            }
            
            return output
        }
    }
    
}
