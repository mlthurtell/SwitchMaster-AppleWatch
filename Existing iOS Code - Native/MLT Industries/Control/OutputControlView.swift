//
//  OutputControlView.swift
//  MLT Industries
//
//  Created by Davis Allie on 30/10/21.
//

import DeviceControl
import SwiftUI

struct OutputControlView: View {
    
    let outputIndex: Int
    let isConnected: Bool
    @Binding var outputMetadata: DeviceOutput
    @Binding var outputControl: Bool
    
    @EnvironmentObject var metadataStore: DeviceMetadataStore
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(outputMetadata.name ?? "Output \(outputIndex + 1)")
                    .font(.headline.bold())
                
                Spacer()
                
                NavigationLink {
                    OutputConfigView(outputIndex: outputIndex, output: $outputMetadata)
                        .environmentObject(metadataStore)
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 4)
            .font(.headline.bold())
            
            
            HStack(alignment: .center) {
                Group {
                    if let image = metadataStore.image(forOutput: outputMetadata, index: outputIndex) {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "photo")
                    }
                }
                .frame(width: 100, height: 64)
                .background(Color(.systemGray6))
                .overlay {
                    ContainerRelativeShape()
                        .stroke(Color.secondary, lineWidth: 2)
                }
                .clipShape(ContainerRelativeShape())
                
                Spacer()
                
                HStack {
                    Text("OFF")
                    Toggle("On", isOn: $outputControl)
                        .labelsHidden()
                    Text("ON")
                }
                .disabled(outputMetadata.isLocked || !isConnected)
                .font(.caption2)
                
                Spacer()
                
                VStack {
                    Image(systemName: outputMetadata.isLocked ? "lock" : "lock.open")
                        .resizable()
                        .scaledToFit()
                    
                    Text((outputMetadata.isLocked ? "Locked" : "Unlocked").uppercased())
                        .font(.caption)
                }
                .foregroundColor(outputMetadata.isLocked ? .red : .green)
                .padding(6)
                .frame(width: 80, height: 64)
                .background(Color(.tertiarySystemBackground))
                .overlay {
                    ContainerRelativeShape()
                        .stroke(Color.secondary, lineWidth: 2)
                }
                .clipShape(ContainerRelativeShape())
                .onLongPressGesture {
                    withAnimation {
                        outputMetadata.isLocked = !outputMetadata.isLocked
                    }
                }
            }
        }
    }
}

struct OutputControlView_Previews: PreviewProvider {
    static var previews: some View {
        OutputControlView(outputIndex: 1, isConnected: true, outputMetadata: .constant(.init()), outputControl: .constant(true))
    }
}
