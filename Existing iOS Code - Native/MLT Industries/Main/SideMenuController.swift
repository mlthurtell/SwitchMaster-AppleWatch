//
//  SideMenuController.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import Foundation

class SideMenuController: ObservableObject {
    
    private weak var viewController: CompactSideMenuContainerViewController?
    private weak var mainParent: RootViewController?
    
    init(viewController: CompactSideMenuContainerViewController, mainParent: RootViewController?) {
        self.viewController = viewController
        self.mainParent = mainParent
    }
    
    func openMenu() {
        viewController?.setMenuOpened(true)
    }
    
    func closeMenu() {
        viewController?.setMenuOpened(true)
    }
    
    func navigateToDeviceControl(index: Int) {
        mainParent?.sidebarItemSelected(.device(index: index))
    }
    
}
