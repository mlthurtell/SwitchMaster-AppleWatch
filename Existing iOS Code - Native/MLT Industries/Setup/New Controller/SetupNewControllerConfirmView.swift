//
//  SetupNewControllerConfirmView.swift
//  MLT Industries
//
//  Created by Davis Allie on 5/4/2022.
//

import DeviceControl
import SwiftUI

struct SetupNewControllerConfirmView: View {
    
    @State private var isLoading = false
    
    @ObservedObject var viewModel = SetupNewControllerViewModel()
    @ObservedObject var bluetoothManager: SwitchMasterDeviceController
    
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    @EnvironmentObject var sideMenuController: SideMenuController
    
    var body: some View {
        VStack {
            Text("Almost there! Please confirm the controller details you entered below.\n\nWhen you are happy, tap 'Complete' to apply these settings to your controller and complete your setup.")
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Image(systemName: "wifi")
                        .imageScale(.small)
                        .frame(width: 32, alignment: .center)
                        .foregroundColor(.red)
                    
                    Text("Device Name: ")
                    
                    Spacer()
                    
                    Text("MLT-\(viewModel.name.text)")
                        .fontWeight(.bold)
                }
                
                HStack(spacing: 0) {
                    Image("bluetooth")
                        .imageScale(.small)
                        .frame(width: 32, alignment: .center)
                        .foregroundColor(.red)
                    
                    Text("Bluetooth PIN: ")
                    
                    Spacer()
                    
                    Text(viewModel.pin.text)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .embedInCardContainer()
            
            Spacer()
            
            Button {
                isLoading = true
                
                bluetoothManager.setConfig(
                    wifiSSID: "MLT-\(viewModel.name.text)",
                    wifiPassword: viewModel.wifiPassword,
                    bluetoothPIN: viewModel.pin.text
                )
                
                let metadata = DeviceMetadata(
                    type: viewModel.controllerType ?? .switchMaster,
                    nickname: viewModel.name.text.replacingOccurrences(of: "MLT-", with: ""),
                    bluetoothIdentifier: bluetoothManager.bluetoothDeviceID,
                    macAddress: bluetoothManager.macAddress,
                    bluetoothPIN: viewModel.pin.text,
                    wifiSSID: viewModel.name.text,
                    wifiPassword: viewModel.wifiPassword
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Disconnect device to allow control manager to connect
                    bluetoothManager.disconnectDevice()
                    
                    let index = metadataStore.insertNewDevice(metadata: metadata)
                    sideMenuController.navigateToDeviceControl(index: index)
                }
            } label: {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Confirm")
                            .fontWeight(.semibold)
                    }
                }
                .frame(width: 250, height: 36)
            }
            .disabled(isLoading)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Add Controller")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

struct SetupNewControllerConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupNewControllerConfirmView(viewModel: .init(), bluetoothManager: .init())
        }
    }
}
