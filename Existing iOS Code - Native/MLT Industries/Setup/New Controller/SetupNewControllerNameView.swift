//
//  SetupNewControllerNameView.swift
//  MLT Industries
//
//  Created by Davis Allie on 5/4/2022.
//

import DeviceControl
import SwiftUI

struct SetupNewControllerNameView: View {
    
    @ObservedObject var viewModel: SetupNewControllerViewModel
    @ObservedObject var bluetoothManager: SwitchMasterDeviceController
    
    @EnvironmentObject var sideMenuController: SideMenuController
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    
    @FocusState private var fieldFocused
    
    var body: some View {
        VStack {
            VStack(spacing: 36) {
                Text("Firstly we need to name your SwitchMaster. This is what you'll search for when connecting to your controller via Wifi or Bluetooth.\n\nWe'll put **MLT-** at the start, so it's easy to distinguish.")
                        .multilineTextAlignment(.center)
                
                VStack(alignment: .leading) {
                    Text("Enter SwitchMaster name:")
                        .font(.subheadline)
                        .bold()
                    
                    TextField("Controller name", text: $viewModel.name.text)
                        .focused($fieldFocused)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("\(viewModel.name.text.count)/\(viewModel.name.characterLimit)")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 4)
                }
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("You'll see:")
                
                Group {
                    Text("MLT-").bold() + Text(viewModel.name.text).bold()
                }
            }
            .frame(maxWidth: .infinity)
            .embedInCardContainer()
            
            Spacer()
            
            NavigationLink {
                SetupNewControllerPasswordsView(viewModel: viewModel, bluetoothManager: bluetoothManager)
                    .environmentObject(metadataStore)
                    .environmentObject(sideMenuController)
            } label: {
                Text("Next")
                    .fontWeight(.semibold)
                    .frame(width: 250, height: 36)
            }
            .disabled(viewModel.name.text == "")
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Add Controller")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct SetupNewControllerNameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupNewControllerNameView(viewModel: .init(), bluetoothManager: .init())
        }
    }
}
