//
//  RootViewController.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import SwiftUI
import UIKit
import DeviceControl

class RootViewController: UISplitViewController, SidebarDelegate {
    
    static var main: RootViewController?
    
    private var smallSideNav: UINavigationController!
    private var smallSideMenu: SidebarViewController!
    private var smallMainNav: UINavigationController!
    private var smallLayoutContainer: CompactSideMenuContainerViewController!
    private var controller: SideMenuController!
    
    private let metadataStore = DeviceMetadataStore()
    
    init() {
        super.init(style: .doubleColumn)
                
        smallSideMenu = SidebarViewController(metadataStore: metadataStore)
        smallSideMenu.delegate = self
        smallSideMenu.navigationItem.title = "MLT Industries"
        smallSideNav = UINavigationController(rootViewController: smallSideMenu)
        smallSideNav.navigationBar.prefersLargeTitles = true
        
        smallMainNav = UINavigationController(rootViewController: UIViewController())
        
        smallLayoutContainer = CompactSideMenuContainerViewController()
        smallLayoutContainer.setSideMenuViewController(smallSideNav)
        smallLayoutContainer.setMainViewController(smallMainNav)
        controller = SideMenuController(viewController: smallLayoutContainer, mainParent: self)
        
        preferredDisplayMode = .oneBesideSecondary
        setViewController(UIViewController(), for: .primary)
        setViewController(UIViewController(), for: .secondary)
        setViewController(smallLayoutContainer, for: .compact)
        Self.main = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleLastControlledDevice()
    }
    
    func handleLastControlledDevice() {
        // TODO: Select last controlled device if available
        let index = UserDefaults.standard.integer(forKey: DeviceMetadataStore.userDefaultsLastDeviceKey)
        if index > 0 {
            sidebarItemSelected(.device(index: index-1))
        } else {
            sidebarItemSelected(.addDevice)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sidebarItemSelected(_ item: SidebarRow) {
        smallLayoutContainer.setMenuOpened(false)
        
        switch item {
        case .device(let index):
            UserDefaults.standard.set(index+1, forKey: DeviceMetadataStore.userDefaultsLastDeviceKey)
            navigateToViewController {
                let root = DeviceControlView(deviceMetadata: metadataStore.metadataBinding(forIndex: index))
                    .environmentObject(controller)
                    .environmentObject(metadataStore)
                
                return UIHostingController(rootView: root)
            }
        case .addDevice:
            navigateToViewController {
                UIHostingController(rootView: SetupInitialView()
                    .environmentObject(controller)
                    .environmentObject(metadataStore)
                )
            }
        case .about:
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            
            let alert = UIAlertController(title: "About", message: "App version: \(appVersion)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel))
            present(alert, animated: true)
        case .faq:
            UIApplication.shared.open(Constants.URLs.faq, options: [:], completionHandler: nil)
        case .contactUs:
            UIApplication.shared.open(Constants.URLs.contact, options: [:], completionHandler: nil)
        }
    }
    
    private func navigateToViewController(_ viewControllerBuilder: () -> UIViewController) {
        let smallCopy = viewControllerBuilder()
        smallMainNav.setViewControllers([smallCopy], animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.window?.tintColor = UIColor(named: "AccentColor")
        
        
    }

}

struct RootView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = RootViewController
    
    func makeUIViewController(context: Context) -> RootViewController {
        RootViewController()
    }
    
    func updateUIViewController(_ uiViewController: RootViewController, context: Context) { }
    
}
