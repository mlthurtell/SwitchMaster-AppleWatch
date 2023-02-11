//
//  DeviceOutput.swift
//  DeviceControl
//
//  Created by Davis Allie on 30/3/2022.
//

import Foundation

public struct DeviceOutput: Codable, Identifiable, Hashable {
    
    public var id: UUID
    public var name: String?
    public var isLocked: Bool = false
    
    public init() {
        self.id = UUID()
        self.name = nil
        self.isLocked = false
    }
    
}
