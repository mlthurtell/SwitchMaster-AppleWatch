//
//  DeviceControllerDelegate.swift
//  DeviceControl
//
//  Created by Davis Allie on 28/6/21.
//

import Foundation

public enum DeviceControllerState {
    case idle, scanning, pairing, connected, disconnected, error(Error)
}

protocol DeviceControllerDelegate: AnyObject {
    
    associatedtype Device: DeviceProtocol
    
    var state: DeviceControllerState { get set }
    
    func deviceStatusReceived(_ status: Device.StatusBufferType)
    func rssiReceived(_ rssi: Int)
    func controllerDidFail(error: Error)
    
}
