//
//  DeviceConfigView.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import DeviceControl
import SwiftUI

class ConfigureDeviceViewModel: ObservableObject {
    
    @Published var name = TextBindingManager(limit: 20, insertMLT: true)
    @Published var pin = TextBindingManager(limit: 6)
    @Published var wifiPassword = "ControlMe"
    
}

struct DeviceConfigView: View {
    
    @Binding var metadata: DeviceMetadata
    @StateObject private var viewModel = ConfigureDeviceViewModel()
    
    @State private var isConfirmingDelete = false
    
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    @EnvironmentObject var controller: SwitchMasterDeviceController
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        VStack {
            VStack(spacing: 36) {
                VStack(alignment: .leading) {
                    Text("\(metadata.type.name) name:")
                        .font(.subheadline)
                        .bold()
                    
                    TextField("Controller name", text: $viewModel.name.text)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("\(viewModel.name.text.count)/\(viewModel.name.characterLimit)")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 4)
                }
                
                VStack(alignment: .leading) {
                    Text("Bluetooth PIN:")
                        .font(.subheadline)
                        .bold()
                    
                    TextField("Bluetooth PIN", text: $viewModel.pin.text)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("\(viewModel.pin.text.count)/\(viewModel.pin.characterLimit)")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 4)
                }
            }
            .padding(.top, 24)
            
            Spacer()
            
            Button {
                metadata.nickname = viewModel.name.text.replacingOccurrences(of: "MLT-", with: "")
                metadata.wifiSSID = viewModel.name.text
                metadata.bluetoothPIN = viewModel.pin.text
                
                metadataStore.save()
                controller.setConfig(
                    wifiSSID: viewModel.name.text,
                    wifiPassword: viewModel.wifiPassword,
                    bluetoothPIN: viewModel.pin.text
                )
                
                dismissAction()
            } label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .frame(width: 250, height: 36)
            }
            .disabled(viewModel.name.text == "" || viewModel.pin.text == "")
            .buttonStyle(.borderedProminent)
            
            Button {
                isConfirmingDelete = true
            } label: {
                Label("Delete Controller", systemImage: "trash")
                    .font(.body.bold())
            }
            .padding(.vertical)
            .alert("Delete Controller", isPresented: $isConfirmingDelete) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteController()
                }
            } message: {
                Text("Are you sure you want to delete this controller from your MLT app?")
            }

        }
        .padding()
        .navigationTitle("Add Controller")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.name.text = metadata.wifiSSID
            viewModel.pin.text = metadata.bluetoothPIN
        }
        
    }
    
    private func deleteController() {
        metadataStore.deleteDevice(metadata: metadata)
        RootViewController.main?.handleLastControlledDevice()
    }
    
}

struct DeviceConfigView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceConfigView(metadata: .constant(.init(type: .switchMaster, nickname: "Name", bluetoothIdentifier: .init(), macAddress: [1,2,3,4,5,6], bluetoothPIN: "123456", wifiSSID: "ControlMe", wifiPassword: "ControlMe")))
                .environmentObject(SwitchMasterDeviceController())
        }
    }
}
