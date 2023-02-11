//
//  OutputConfigView.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import DeviceControl
import SwiftUI

class ConfigureOutputViewModel: ObservableObject {
    
    @Published var name = TextBindingManager(limit: 20, insertMLT: false)
    @Published var image: UIImage?
    
}

struct OutputConfigView: View {
    
    let outputIndex: Int
    @Binding var output: DeviceOutput
    @StateObject private var viewModel = ConfigureOutputViewModel()
    
    @State private var isShowingCameraCapture = false
    @State private var isShowingImagePicker = false
    
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        VStack {
            VStack(spacing: 36) {
                VStack(alignment: .leading) {
                    Text("Output \(outputIndex+1):")
                        .font(.subheadline)
                        .bold()
                    
                    TextField("Output nickname", text: $viewModel.name.text)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("\(viewModel.name.text.count)/\(viewModel.name.characterLimit)")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 4)
                }
                
                VStack(alignment: .leading) {
                    Text("Image:")
                        .font(.subheadline)
                        .bold()
                    
                    Group {
                        if let image = viewModel.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Color.gray
                                
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    HStack(spacing: 16) {
                        Menu {
                            Button {
                                isShowingCameraCapture = true
                            } label: {
                                Label("From camera", systemImage: "camera")
                            }
                            
                            Button {
                                isShowingImagePicker = true
                            } label: {
                                Label("From photo library", systemImage: "photo")
                            }
                        } label: {
                            Text("\(viewModel.image == nil ? "Add" : "Replace") Image")
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .fullScreenCover(isPresented: $isShowingCameraCapture.animation()) {
                            CameraCapture(image: $viewModel.image)
                        }
                        .fullScreenCover(isPresented: $isShowingImagePicker.animation()) {
                            ImagePicker(image: $viewModel.image)
                                .ignoresSafeArea()
                        }
                        
                        if viewModel.image != nil {
                            Button("Remove Image") {
                                viewModel.image = nil
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, 24)
            
            Spacer()
            
            Button {
                output.name = viewModel.name.text == "" ? nil : viewModel.name.text
                
                if let image = viewModel.image {
                    metadataStore.saveImage(image, forOutput: output, index: outputIndex)
                } else {
                    metadataStore.removeImage(forOutput: output, index: outputIndex)
                }
                
                metadataStore.save()
                dismissAction()
            } label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .frame(width: 250, height: 36)
            }
            .buttonStyle(.borderedProminent)
        }
        .ignoresSafeArea(.keyboard)
        .padding()
        .navigationTitle("Configure Output")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.name.text = output.name ?? ""
            
            if let image = metadataStore.uiImage(forOutput: output, index: outputIndex) {
                viewModel.image = image
            }
        }
        
    }
    
}
