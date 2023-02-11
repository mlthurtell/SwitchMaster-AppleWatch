//
//  SetupNewControllerViewModel.swift
//  MLT Industries
//
//  Created by Davis Allie on 5/4/2022.
//

import DeviceControl
import Foundation

class SetupNewControllerViewModel: ObservableObject {
    
    @Published var controllerType: DeviceMetadata.ControllerType?
    @Published var name = TextBindingManager(limit: 16, insertMLT: false)
    @Published var pin = TextBindingManager(limit: 6)
    @Published var wifiPassword = "ControlMe"
    
}
