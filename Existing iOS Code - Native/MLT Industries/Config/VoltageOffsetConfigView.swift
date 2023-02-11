//
//  VoltageOffsetConfigView.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import DeviceControl
import SwiftUI

struct VoltageOffsetConfigView: View {
    
    @State private var offset: Double = 0.0
    
    @Binding var metadata: DeviceMetadata
    
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    @EnvironmentObject var controller: SwitchMasterDeviceController
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("This voltage offset will be applied to all voltage readings from your controller to adjust for manufacturing variations.\n\nThis will not affect the measured current from the controller.")
            
            HStack(spacing: 16) {
                VStack {
                    Slider(value: $offset, in: -1 ... 1)
                    HStack {
                        Text("-1.0V")
                        Spacer()
                        Text("0.0V")
                        Spacer()
                        Text("1.0V")
                    }
                    .font(.caption)
                }
                
                
                VStack(alignment: .leading) {
                    Text("Offset")
                        .font(.caption.bold())
                    TextField("Offset", value: $offset, format: .number.precision(.fractionLength(2)))
                        .textFieldStyle(.roundedBorder)
                }
                .frame(width: 80)
            }
            
            VStack {
                HStack {
                    Text("Measured Voltage: ")
                        .frame(width: 160, alignment: .leading)
                    
                    Text("\(controller.batteryVoltage.converted(to: .volts).value.formatted(.number.precision(.fractionLength(2))))V")
                        .bold()
                        .foregroundColor(.accentColor)
                        .frame(width: 100, alignment: .leading)
                }
                
                HStack {
                    Text("Adjusted Voltage: ")
                        .frame(width: 160, alignment: .leading)
                    
                    Text("\((controller.batteryVoltage.converted(to: .volts).value + offset).formatted(.number.precision(.fractionLength(2))))V")
                        .bold()
                        .foregroundColor(.accentColor)
                        .frame(width: 100, alignment: .leading)
                }
            }
            
            Button {
                metadata.voltageOffset = offset
                metadataStore.save()
                
                dismissAction()
            } label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .frame(width: 250, height: 36)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Configuration")
    }
    
}
