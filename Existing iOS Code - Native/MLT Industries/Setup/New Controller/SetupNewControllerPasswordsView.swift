//
//  SetupNewControllerPasswordsView.swift
//  MLT Industries
//
//  Created by Davis Allie on 5/4/2022.
//

import DeviceControl
import SwiftUI

struct SetupNewControllerPasswordsView: View {
    
    @ObservedObject var viewModel = SetupNewControllerViewModel()
    @ObservedObject var bluetoothManager: SwitchMasterDeviceController
    
    @EnvironmentObject var sideMenuController: SideMenuController
    @EnvironmentObject var metadataStore: DeviceMetadataStore
        
    var body: some View {
        VStack {
            VStack(spacing: 36) {
                Text("Next we'll configure your custom passwords for your SwitchMaster. This is what you'll use when connecting to your controller on another phone or outside of the MLT app.")
                        .multilineTextAlignment(.center)
                
                VStack(alignment: .leading) {
                    Text("Enter Bluetooth PIN:")
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
            
            NavigationLink {
                SetupNewControllerConfirmView(viewModel: viewModel, bluetoothManager: bluetoothManager)
                    .environmentObject(metadataStore)
                    .environmentObject(sideMenuController)
            } label: {
                Text("Next")
                    .fontWeight(.semibold)
                    .frame(width: 250, height: 36)
            }
            .disabled(viewModel.pin.text == "")
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Add Controller")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SetupNewControllerPasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupNewControllerPasswordsView(viewModel: .init(), bluetoothManager: .init())
        }
    }
}
