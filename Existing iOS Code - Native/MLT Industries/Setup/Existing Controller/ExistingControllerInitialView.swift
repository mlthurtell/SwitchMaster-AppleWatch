//
//  ExistingControllerInitialView.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import DeviceControl
import SwiftUI

struct ExistingControllerInitialView: View {
    
    @State private var controllerType: DeviceMetadata.ControllerType = .switchMaster
    @StateObject private var name = TextBindingManager(limit: 20, insertMLT: true)
    @StateObject private var pin = TextBindingManager(limit: 6)
    
    @State private var isConnecting = false
    @State private var hasConnected = false
    @StateObject var bluetoothManager = SwitchMasterDeviceController(isForIntialSetup: true)
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    @EnvironmentObject var sideMenuController: SideMenuController
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Please enter the details of your controller below and tap \"Connect\" when done.")
                .multilineTextAlignment(.center)
                .padding(.bottom, 36)
            
            HStack {
                Text("Controller type:")
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Picker(selection: $controllerType) {
                    ForEach(DeviceMetadata.ControllerType.allCases, id: \.rawValue) { type in
                        Text(type.name).tag(type)
                    }
                } label: {
                    Text(controllerType.name)
                        .font(.body)
                        .fixedSize()
                }
                .pickerStyle(.menu)
            }
            .font(.body)
            .padding(.vertical)
            
            VStack(alignment: .leading) {
                Text("Controller name:")
                    .font(.subheadline)
                    .bold()
                
                TextField("Controller name", text: $name.text)
                
                Text("\(name.text.count)/\(name.characterLimit)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 4)
            }
            
            VStack(alignment: .leading) {
                Text("Bluetooth PIN:")
                    .font(.subheadline)
                    .bold()
                
                TextField("Bluetooth PIN", text: $pin.text)
                    .keyboardType(.numberPad)
                
                Text("\(pin.text.count)/\(pin.characterLimit)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 4)
            }
            
            Spacer()
            
            Button {
                isConnecting = true
                bluetoothManager.scanForDevice()
            } label: {
                Group {
                    if isConnecting {
                        ProgressView()
                    } else {
                        Text("Connect")
                            .fontWeight(.semibold)
                    }
                }
                .frame(width: 250, height: 36)
            }
            .disabled(isConnecting || name.text == "" || pin.text == "")
            .buttonStyle(.borderedProminent)
        }
        .onReceive(bluetoothManager.$state) { state in
            switch state {
            case .scanning, .pairing:
                isConnecting = true
            case .connected:
                isConnecting = false
                
                let metadata = DeviceMetadata(
                    type: controllerType,
                    nickname: name.text.replacingOccurrences(of: "MLT-", with: ""),
                    bluetoothIdentifier: bluetoothManager.bluetoothDeviceID,
                    macAddress: bluetoothManager.macAddress,
                    bluetoothPIN: pin.text,
                    wifiSSID: name.text,
                    wifiPassword: "ControlMe"
                )
                
                // Disconnect device to allow control manager to connect
                bluetoothManager.disconnectDevice()
                
                let index = metadataStore.insertNewDevice(metadata: metadata)
                sideMenuController.navigateToDeviceControl(index: index)
            case .disconnected, .error(_), .idle:
                isConnecting = false
            }
        }
        .alert("Error", isPresented: bluetoothManager.hasError, presenting: bluetoothManager.error) { error in
            Button("OK") {}
        } message: { error in
            Text(error.error.localizedDescription)
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .navigationTitle("Add Controller")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExistingControllerInitialView_Previews: PreviewProvider {
    static var previews: some View {
        ExistingControllerInitialView()
    }
}
