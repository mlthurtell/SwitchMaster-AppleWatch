//
//  SetupInitialView.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import DeviceControl
import SwiftUI

struct SetupInitialView: View {
    
    @EnvironmentObject var sideMenuController: SideMenuController
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    
    var body: some View {
        VStack {
            Image("mlt_text_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 44)
                .foregroundColor(.accentColor)
            
            VStack {
                Text("Welcome!")
                    .font(.largeTitle.bold())
                
                Text("Let's get started by adding an\nMLT controller to your app.")
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack {
                Text("Got a new controller you\nneed to setup?")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Tap the Setup button to get started")
                
                NavigationLink {
                    SetupNewControllerInitialView()
                        .environmentObject(metadataStore)
                        .environmentObject(sideMenuController)
                } label: {
                    Text("Setup")
                        .fontWeight(.semibold)
                        .padding(8)
                        .frame(width: 250)
                }
                .buttonStyle(.borderedProminent)
            }
            .multilineTextAlignment(.center)
            
            Spacer()
            
            VStack {
                Text("Got an existing controller you\nwant to control from this phone?")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Tap the Connect button to get started")
                
                NavigationLink {
                    ExistingControllerInitialView()
                } label: {
                    Text("Connect")
                        .fontWeight(.semibold)
                        .padding(8)
                        .frame(width: 250)
                }
                .buttonStyle(.borderedProminent)
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Add Controller")
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
        }
    }
}

struct SetupInitialView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupInitialView()
        }
    }
}
