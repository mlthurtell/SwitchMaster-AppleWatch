//
//  TextBindingManager.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import Foundation

class TextBindingManager: ObservableObject {
    @Published var text = "" {
        didSet {
            if text.count == 1 && insertMLT {
                self.text = "MLT-" + text
            }
            
            if text.count > characterLimit {
                text = oldValue
            }
        }
    }
    
    let characterLimit: Int
    let insertMLT: Bool

    init(limit: Int = 5, insertMLT: Bool = false) {
        characterLimit = limit
        self.insertMLT = insertMLT
    }
}
