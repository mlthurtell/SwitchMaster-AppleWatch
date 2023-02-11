//
//  SwitchMasterDeviceController.swift
//  DeviceControl
//
//  Created by Davis Allie on 4/4/2022.
//

import Foundation
import SwiftUI

public class SwitchMasterDeviceController: ObservableObject, DeviceControllerDelegate {
    
    typealias Device = SwitchMasterDeviceSnapshot
    
    private var bluetoothController: BluetoothDeviceController<Device.StatusBufferType, Device.ControlBufferType, Device.ConfigBufferType, SwitchMasterDeviceController>!
    
    @Published public var state: DeviceControllerState = .idle
    public var isConnected: Bool {
        switch state {
        case .connected:
            return true
        default:
            return false
        }
    }
    
    @Published public var macAddress: [Int] = []
    @Published public var batteryVoltage = Measurement(value: 0.0, unit: UnitElectricPotentialDifference.volts)
    @Published public var totalCurrentDraw = Measurement(value: 0.0, unit: UnitElectricCurrent.amperes)
    @Published public var rssi = 0
    @Published public var outputStates = Array(repeating: false, count: 10) {
        didSet {
            _snapshot.outputStates = self.outputStates
            sendControlRequest()
        }
    }
    
    public struct ErrorWrapper: Identifiable {
        public var id = UUID()
        public var error: Error
    }
    
    public var bluetoothDeviceID: UUID {
        bluetoothController.deviceId!
    }
    
    @Published public var error: ErrorWrapper?
    public var hasError: Binding<Bool> {
        Binding {
            self.error != nil
        } set: { has in
            if !has {
                self.error = nil
            }
        }
    }
    
    private var _snapshot = SwitchMasterDeviceSnapshot() {
        didSet {
            self.macAddress = _snapshot.macAddress
            self.batteryVoltage = _snapshot.batteryVoltage
            self.totalCurrentDraw = _snapshot.totalCurrentDraw
        }
    }
    
    public init(deviceId: UUID? = nil, isForIntialSetup: Bool = false) {
        bluetoothController = BluetoothDeviceController(deviceId: deviceId, delegate: self, isForInitialSetup: isForIntialSetup)
    }
    
    public func setConfig(wifiSSID: String, wifiPassword: String, bluetoothPIN: String) {
        print(macAddress, wifiSSID, wifiPassword, bluetoothPIN)
        
        bluetoothController.sendConfigRequest(
            .init(
                macAddress: macAddress,
                ssid: wifiSSID,
                wifiPassword: wifiPassword,
                bluetoothPin: Int(bluetoothPIN) ?? 0
            )
        )
    }
    
    public func refreshDevice() {
        bluetoothController.readLatestStatus()
        bluetoothController.readRSSI()
    }
    
    public func scanForDevice() {
        bluetoothController.scanForSwitchMasterDevice()
    }
    
    public func disconnectDevice() {
        bluetoothController.disconnect()
    }
    
    private func sendControlRequest() {
        let buffer = try! _snapshot.createControlBuffer()
        bluetoothController.sendControlRequest(buffer)
    }
    
    func deviceStatusReceived(_ status: SwitchMasterDeviceSnapshot.StatusByteBuffer) {
        DispatchQueue.main.async {
            self._snapshot.applyStatusData(buffer: status)
            
            // Update outputs here rather than snapshot "didSet" to avoid infinite loop
            self.outputStates = self._snapshot.outputStates
        }
    }
    
    func rssiReceived(_ rssi: Int) {
        DispatchQueue.main.async {
            self.rssi = rssi
        }
    }
    
    func controllerDidFail(error: Error) {
        self.error = ErrorWrapper(error: error)
    }
    
}
