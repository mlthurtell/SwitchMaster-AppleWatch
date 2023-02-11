//
//  DeviceControlView.swift
//  MLT Industries
//
//  Created by Davis Allie on 30/10/21.
//

import DeviceControl
import SwiftUI

struct DeviceControlView: View {
    
    init(deviceMetadata: Binding<DeviceMetadata>) {
        self._metadata = deviceMetadata
        self._controller = StateObject(wrappedValue: SwitchMasterDeviceController(deviceId: deviceMetadata.bluetoothIdentifier.wrappedValue))
    }
    
    @Binding var metadata: DeviceMetadata
    @StateObject var controller: SwitchMasterDeviceController
    
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    @EnvironmentObject var sideMenuController: SideMenuController
    
    var body: some View {
        ScrollView {
            DeviceStatusView(metadata: $metadata)
                .frame(maxWidth: .infinity, alignment: .leading)
                .embedInCardContainer()
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(0 ..< metadata.outputs.count) { i in
                    OutputControlView(outputIndex: i, isConnected: controller.isConnected, outputMetadata: $metadata.outputs[i], outputControl: $controller.outputStates[i])
                        .embedInCardContainer(horizontalPadding: 8, verticalPadding: 8)
                }
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    sideMenuController.openMenu()
                } label: {
                    Image(systemName: "sidebar.left")
                        .imageScale(.large)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Image("mlt_text_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                    .foregroundColor(.accentColor)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    DeviceConfigView(metadata: $metadata)
                        .environmentObject(controller)
                        .environmentObject(metadataStore)
                } label: {
                    Image(systemName: "gear")
                        .imageScale(.large)
                }
            }
        }
        .environmentObject(controller)
        .environmentObject(metadataStore)
    }
    
}
