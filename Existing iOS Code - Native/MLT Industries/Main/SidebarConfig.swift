//
//  SidebarConfig.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import UIKit

protocol SidebarDelegate: AnyObject {
    
    func sidebarItemSelected(_ item: SidebarRow)
    
}

enum SidebarSection: Int {
    case devices, addDevice, info
}

struct SidebarItem: Hashable {
    let title: String
    let image: UIImage?
    let row: SidebarRow
    
    static func row(title: String, image: UIImage?, row: SidebarRow) -> Self {
        SidebarItem(title: title, image: image, row: row)
    }
}

enum SidebarRow: Hashable {
    case device(index: Int)
    
    case addDevice
    
    case faq
    case contactUs
    case about
}
