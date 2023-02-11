//
//  DeviceProtocol.swift
//  DeviceControl
//
//  Created by Davis Allie on 21/7/21.
//

import Foundation

protocol DeviceProtocol {
    
    associatedtype StatusBufferType: ByteBufferDecodable
    associatedtype ControlBufferType: ByteBufferEncodable
    associatedtype ConfigBufferType: ByteBufferEncodable
    
    mutating func applyStatusData(buffer: StatusBufferType)
    func createControlBuffer() throws -> ControlBufferType
    
    static func dummyControlBuffer() -> ControlBufferType
    
}
