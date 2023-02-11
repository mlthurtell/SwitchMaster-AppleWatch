//
//  DeviceMetadataStore.swift
//  DeviceControl
//
//  Created by Davis Allie on 30/3/2022.
//

import Foundation
import SwiftUI

public class DeviceMetadataStore: ObservableObject {
    
    @Published public var devices: [DeviceMetadata] = []
    
    public static let userDefaultsLastDeviceKey = "MLT_LAST_DEVICE_INDEX_V4"
    private let userDefaultsKey = "MLT_DEVICE_METADATA_V4"
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    
    private let baseDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var imageCache: [String: Image] = [:]
    
    public init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey), let devices = try? decoder.decode([DeviceMetadata].self, from: data) {
            self.devices = devices
        }
        
        #if DEBUG
        if devices.isEmpty {
            devices.append(
                .init(
                    type: .switchMaster,
                    nickname: "Test Device",
                    bluetoothIdentifier: UUID(),
                    macAddress: [1,2,3,4,5,6],
                    bluetoothPIN: "123456",
                    wifiSSID: "MLT-Device",
                    wifiPassword: "ControlMe"
                )
            )
        }
        #endif
    }
    
    public func save() {
        guard let data = try? encoder.encode(devices) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    public func insertNewDevice(metadata: DeviceMetadata) -> Int {
        devices.append(metadata)
        save()
        
        return devices.count-1
    }
    
    public func metadataBinding(forIndex index: Int) -> Binding<DeviceMetadata> {
        .init {
            if index < self.devices.count {
                return self.devices[index]
            } else {
                return .init(type: .switchMaster, nickname: "", bluetoothIdentifier: .init(), macAddress: [], bluetoothPIN: "", wifiSSID: "", wifiPassword: "")
            }
        } set: { metadata in
            self.devices[index] = metadata
            self.save()
        }
    }
    
    public func deleteDevice(metadata: DeviceMetadata) {
        devices.removeAll {
            $0.id == metadata.id
        }
        
        UserDefaults.standard.removeObject(forKey: Self.userDefaultsLastDeviceKey)
        save()
    }
    
    private func imagePath(forOutput output: DeviceOutput, index: Int) -> URL {
        baseDocumentsDirectory.appendingPathComponent("\(output.id.uuidString)-\(index).jpg")
    }
    
    public func removeImage(forOutput output: DeviceOutput, index: Int) {
        let path = imagePath(forOutput: output, index: index)
        if FileManager.default.fileExists(atPath: path.path) {
            try? FileManager.default.removeItem(at: path)
        }
        
        imageCache["\(output.id)-\(index)"] = nil
    }
    
    public func saveImage(_ image: UIImage, forOutput output: DeviceOutput, index: Int) {
        let path = imagePath(forOutput: output, index: index)
        imageCache["\(output.id)-\(index)"] = Image(uiImage: image)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: path)
        }
    }
    
    public func uiImage(forOutput output: DeviceOutput, index: Int) -> UIImage? {
        let path = imagePath(forOutput: output, index: index)
        if FileManager.default.fileExists(atPath: path.path) {
            return UIImage(contentsOfFile: path.path)
        } else {
            return nil
        }
    }
    
    public func image(forOutput output: DeviceOutput, index: Int) -> Image? {
        if let cached = imageCache["\(output.id)-\(index)"] {
            return cached
        }
        let path = imagePath(forOutput: output, index: index)
        if FileManager.default.fileExists(atPath: path.path) {
            if let data = UIImage(contentsOfFile: path.path) {
                let image = Image(uiImage: data)
                imageCache["\(output.id)-\(index)"] = image
                return image
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
}
