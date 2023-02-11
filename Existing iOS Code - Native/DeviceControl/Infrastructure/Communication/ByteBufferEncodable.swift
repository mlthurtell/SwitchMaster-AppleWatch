//
//  ByteBufferEncodable.swift
//  DeviceControl
//
//  Created by Davis Allie on 21/7/21.
//

import Foundation

public protocol ByteBufferEncodable {
    
    func toByteBuffer() throws -> Data
    
}
