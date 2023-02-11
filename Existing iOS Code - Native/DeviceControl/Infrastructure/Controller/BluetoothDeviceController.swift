//
//  BluetoothDeviceController.swift
//  DeviceControl
//
//  Created by Davis Allie on 28/6/21.
//

import CoreBluetooth
import Foundation
import Sentry

class BluetoothDeviceController<StatusType, ControlRequestType, ConfigRequestType, Delegate: DeviceControllerDelegate>: NSObject, ObservableObject, CBPeripheralDelegate, CBCentralManagerDelegate where StatusType == Delegate.Device.StatusBufferType, ControlRequestType == Delegate.Device.ControlBufferType, ConfigRequestType == Delegate.Device.ConfigBufferType {
        
    var state: DeviceControllerState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.state = self.state
            }
        }
    }
    
    weak var delegate: Delegate?
    
    var deviceId: UUID?
    private var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var isForInitialSetup: Bool
    
    private var primaryService: CBService!
    private var readCharacteristic: CBCharacteristic!
    private var controlCharacteristic: CBCharacteristic!
    private var configCharacteristic: CBCharacteristic!
    private var isSendingRequest: Bool
        
    init(deviceId: UUID? = nil, delegate: Delegate? = nil, isForInitialSetup: Bool = false) {
        self.deviceId = deviceId
        self.delegate = delegate
        self.isForInitialSetup = isForInitialSetup
        self.isSendingRequest = false
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: .global(qos: .userInitiated))
        if deviceId != nil {
            SentrySDK.capture(message: "Scanning for device ID \(deviceId!)")
            scanForSwitchMasterDevice()
        }
    }
    
    deinit {
        disconnect()
    }
    
    public func scanForSwitchMasterDevice() {
        SentrySDK.capture(message: "Start BT scanning")
        self.state = .scanning
        centralManager.scanForPeripherals(
            withServices: [DeviceConfiguration.switchMaster.serviceUUID],
            options: [:]
        )
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Found peripheral: \(peripheral)")
        SentrySDK.capture(message: "Found periperhal services \(peripheral.services ?? [])")
        guard let service = peripheral.services?.first, error == nil else {
            return
        }
        
        peripheral.discoverCharacteristics([
            CharacteristicConfiguration.switchMaster.readUUID,
            CharacteristicConfiguration.switchMaster.writeUUID,
            CharacteristicConfiguration.switchMaster.configUUID,
        ], for: service)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        SentrySDK.capture(message: "Found service characteristics \(service.characteristics ?? [])")
        
        for characteristic in service.characteristics ?? [] {
            switch characteristic.uuid {
            case CharacteristicConfiguration.switchMaster.readUUID:
                self.readCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: readCharacteristic)
                self.readLatestStatus()
            case CharacteristicConfiguration.switchMaster.writeUUID:
                self.controlCharacteristic = characteristic
                
                if isForInitialSetup {
                    self.sendControlRequest(Delegate.Device.dummyControlBuffer(), isInitial: true)
                } else {
                    self.state = .connected
                }
            case CharacteristicConfiguration.switchMaster.configUUID:
                self.configCharacteristic = characteristic
            default:
                break
            }
        }
    }
    
    func readLatestStatus() {
        SentrySDK.capture(message: "Reading device status")
        peripheral?.readValue(for: readCharacteristic)
    }
    
    func readRSSI() {
        SentrySDK.capture(message: "Reading RSSI")
        peripheral?.readRSSI()
    }
    
    func sendControlRequest(_ request: ControlRequestType, isInitial: Bool = false) {
        SentrySDK.capture(message: "Sending control request")
        do {
            let data = try request.toByteBuffer()
            
            if !isInitial {
                isSendingRequest = true
            }
            
            peripheral?.writeValue(data, for: controlCharacteristic, type: .withResponse)
        } catch {
            SentrySDK.capture(error: error)
            delegate?.controllerDidFail(error: error)
        }
    }
    
    func sendConfigRequest(_ request: ConfigRequestType) {
        SentrySDK.capture(message: "Sending config request")
        do {
            let data = try request.toByteBuffer()
            isSendingRequest = true
            peripheral?.writeValue(data, for: configCharacteristic, type: .withResponse)
        } catch {
            SentrySDK.capture(error: error)
            delegate?.controllerDidFail(error: error)
        }
    }
    
    func disconnect() {
        if let peripheral = peripheral {
            SentrySDK.capture(message: "Disconnecting peripheral")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Read error: \(error)")
        SentrySDK.capture(message: "Did received characteristic value \(characteristic.uuid)")
        
        guard characteristic == readCharacteristic, !isSendingRequest && error == nil else {
            return
        }
        
        guard let data = characteristic.value, error == nil else {
            SentrySDK.capture(error: error!)
            delegate?.controllerDidFail(error: error!)
            return
        }
        
        do {
            let converted = try StatusType(byteBuffer: data)
            delegate?.deviceStatusReceived(converted)
        } catch {
            SentrySDK.capture(error: error)
            delegate?.controllerDidFail(error: error)
        }
    }
    
    /**
     Here we send a dummy empty config request that will be ignored by the controller to determine the paired status
     iOS doesn't prompt for the PIN up front and has no way of detecting once entered other than attempting
     to communicate with the device
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Write error: \(error), \(characteristic)")
        print(characteristic.value ?? Data())
        
        isSendingRequest = false
        
        guard characteristic == controlCharacteristic, error == nil else {
            return
        }
        
        // If write succeeds, device has been paired
        if case .pairing = state {
            state = .connected
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        SentrySDK.capture(message: "Did read RSSI \(RSSI)")
        
        guard error == nil else {
            SentrySDK.capture(error: error!)
            delegate?.controllerDidFail(error: error!)
            return
        }
        
        delegate?.rssiReceived(RSSI.intValue)
    }
    
    
    // MARK: - CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        SentrySDK.capture(message: "Discovered peripheral \(peripheral.identifier)")
        
        if let existingId = deviceId, peripheral.identifier != existingId {
            // We have detected a different device so a different manager should be used
            return
        }
        
        self.peripheral = peripheral
        self.deviceId = peripheral.identifier
        self.state = .pairing
        
        central.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        SentrySDK.capture(message: "Connected peripheral \(peripheral.identifier)")
        
        peripheral.delegate = self
        peripheral.discoverServices([DeviceConfiguration.switchMaster.serviceUUID])
        readRSSI()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        state = .disconnected
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        SentrySDK.capture(error: error!)
        state = .error(error!)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {}
    
}
