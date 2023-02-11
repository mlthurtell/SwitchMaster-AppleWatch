//
//  SetupNewControllerInitialView.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import DeviceControl
import SwiftUI

struct SetupNewControllerInitialView: View {
    
    @State private var isConnecting = false
    @StateObject var viewModel = SetupNewControllerViewModel()
    @StateObject var bluetoothManager = SwitchMasterDeviceController(isForIntialSetup: true)
    
    @State private var hasConnected = false
    
    @EnvironmentObject var sideMenuController: SideMenuController
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("Congratulations!")
                    .font(.largeTitle.bold())
                
                Text("Congratulations on purchasing your new SwitchMaster controller. This wizard will walk you through setting up the controller and the app.")
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            
            Spacer()
            
            HStack {
                Text("Controller type:")
                
                Spacer()
                
                Picker(selection: $viewModel.controllerType) {
                    ForEach(DeviceMetadata.ControllerType.allCases, id: \.rawValue) { type in
                        Text(type.name).tag(type as DeviceMetadata.ControllerType?)
                    }
                } label: {
                    Text(viewModel.controllerType?.name ?? "Select")
                        .font(.body)
                        .fixedSize()
                }
                .pickerStyle(.menu)
            }
            .font(.body)
            
            Spacer()
            
            VStack {
                Text("The default connectivity values are:")
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "wifi")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                            .frame(width: 32)
                        Text("Device Name:")
                        Spacer()
                        Text("MLT_Industries")
                            .bold()
                    }
                    
                    /*HStack {
                        Image(systemName: "lock.shield")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                            .frame(width: 32)
                        Text("WiFi Password:")
                        Spacer()
                        Text("ControlMe")
                            .bold()
                    }*/
                    
                    HStack {
                        Image("bluetooth")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                            .frame(width: 32)
                        Text("Bluetooth PIN:")
                        Spacer()
                        Text("123456")
                            .bold()
                    }
                }
                .embedInCardContainer()
            }
            .multilineTextAlignment(.center)
            
            Spacer()
            
            VStack {
                Text("Tap \"Connect\" below to connect to your controller over Bluetooth")
                
                Button {
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
                .disabled(isConnecting || viewModel.controllerType == nil)
                .buttonStyle(.borderedProminent)
            }
            .multilineTextAlignment(.center)
        }
        .onReceive(bluetoothManager.$state) { state in
            switch state {
            case .scanning, .pairing:
                isConnecting = true
            case .connected:
                isConnecting = false
                hasConnected = true
            case .disconnected, .error(_), .idle:
                isConnecting = false
            }
        }
        .background {
            NavigationLink(isActive: $hasConnected) {
                SetupNewControllerNameView(viewModel: viewModel, bluetoothManager: bluetoothManager)
                    .environmentObject(metadataStore)
                    .environmentObject(sideMenuController)
            } label: {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Add Controller")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SetupNewControllerInitialView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNewControllerInitialView()
            .environmentObject(DeviceMetadataStore())
            .environmentObject(SideMenuController(viewController: .init(), mainParent: .init()))
    }
}
