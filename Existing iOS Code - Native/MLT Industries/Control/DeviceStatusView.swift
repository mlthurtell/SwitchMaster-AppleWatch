//
//  DeviceStatusView.swift
//  MLT Industries
//
//  Created by Davis Allie on 30/10/21.
//

import DeviceControl
import SwiftUI

struct DeviceStatusView: View {
    
    @Binding var metadata: DeviceMetadata
    
    @EnvironmentObject var metadataStore: DeviceMetadataStore
    @EnvironmentObject var controller: SwitchMasterDeviceController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            informationRow(
                icon: .init(systemName: "battery.100"),
                name: "Battery Voltage",
                formattedAmount: "\((controller.batteryVoltage.converted(to: .volts).value + metadata.voltageOffset).formatted(.number.precision(.fractionLength(2))))V"
            )
            
            informationRow(
                icon: .init(systemName: "bolt.fill"),
                name: "Total Draw",
                formattedAmount: controller.totalCurrentDraw.formatted()
            )
            
            switch controller.rssi {
            case Int.min ... -90:
                informationRow(
                    icon: .init(systemName: "wifi"),
                    name: "Signal Strength",
                    formattedAmount: "Poor"
                )
            case -89 ... -80:
                informationRow(
                    icon: .init(systemName: "wifi"),
                    name: "Signal Strength",
                    formattedAmount: "Average"
                )
            case -79 ... -70:
                informationRow(
                    icon: .init(systemName: "wifi"),
                    name: "Signal Strength",
                    formattedAmount: "Good"
                )
            default:
                informationRow(
                    icon: .init(systemName: "wifi"),
                    name: "Signal Strength",
                    formattedAmount: "Excellent"
                )
            }
        }
        /*.opacity(controller.isConnected ? 1 : 0)
        .overlay {
            switch controller.state {
            case .connected:
                EmptyView()
            case .error(let error):
                VStack {
                    Text("Error")
                        .font(.title2)
                    Text(error.localizedDescription)
                }
            default:
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Connecting...")
                }
            }
        }*/
        .overlay {
            NavigationLink {
                VoltageOffsetConfigView(metadata: $metadata)
                    .environmentObject(controller)
                    .environmentObject(metadataStore)
            } label: {
                Image(systemName: "pencil")
                    .font(.title3.bold())
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }
    
    private func informationRow(icon: Image, name: String, formattedAmount: String) -> some View {
        HStack(spacing: 0) {
            icon
                .imageScale(.small)
                .frame(width: 32, alignment: .center)
                .foregroundColor(.red)
            
            Text(name + ": ")
            
            Text(formattedAmount)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Spacer()
        }
    }
    
}
