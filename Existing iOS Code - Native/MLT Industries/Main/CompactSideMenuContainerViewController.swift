//
//  CompactSideMenuContainerViewController.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import UIKit

class CompactSideMenuContainerViewController: UIViewController {
    
    private let visibleMenuWidth: CGFloat = 300
    private let menuSheetWidth: CGFloat = 450
    
    private var menuSheet: UIView!
    private var menuSheetPositionConstraint: NSLayoutConstraint!
    private var mainContent: UIView!
    private var mainDimmingOverlay: UIView!
    
    private weak var sideMenuVC: UIViewController?
    private weak var mainVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainContent = UIView()
        mainContent.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContent)
        
        mainDimmingOverlay = UIView()
        mainDimmingOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainDimmingOverlay)
        mainDimmingOverlay.backgroundColor = .black
        mainDimmingOverlay.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOutsideMenu))
        mainDimmingOverlay.addGestureRecognizer(tap)
        
        menuSheet = UIView()
        menuSheet.translatesAutoresizingMaskIntoConstraints = false
        menuSheet.backgroundColor = .systemGroupedBackground
        menuSheet.layer.shadowOpacity = 0
        menuSheet.layer.shadowRadius = 8
        menuSheet.layer.shadowOffset = CGSize(width: 2, height: 0)
        
        view.addSubview(menuSheet)
        menuSheetPositionConstraint = menuSheet.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        NSLayoutConstraint.activate([
            menuSheet.topAnchor.constraint(equalTo: view.topAnchor),
            menuSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuSheetPositionConstraint,
            menuSheet.widthAnchor.constraint(equalToConstant: menuSheetWidth),
            mainContent.topAnchor.constraint(equalTo: view.topAnchor),
            mainContent.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainContent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainDimmingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            mainDimmingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainDimmingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainDimmingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    public func setSideMenuViewController(_ viewController: UIViewController) {
        loadViewIfNeeded()
        
        if let old = sideMenuVC {
            old.view.removeFromSuperview()
            old.removeFromParent()
        }
        
        viewController.willMove(toParent: self)
        addChild(viewController)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        menuSheet.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: menuSheet.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: menuSheet.bottomAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: menuSheet.trailingAnchor),
            viewController.view.widthAnchor.constraint(equalToConstant: visibleMenuWidth)
        ])
        
        viewController.didMove(toParent: self)
        
        sideMenuVC = viewController
    }
    
    public func setMainViewController(_ viewController: UIViewController) {
        loadViewIfNeeded()
        
        if let old = mainVC {
            old.view.removeFromSuperview()
            old.removeFromParent()
        }
        
        viewController.willMove(toParent: self)
        addChild(viewController)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        mainContent.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: mainContent.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: mainContent.bottomAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: mainContent.trailingAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: mainContent.leadingAnchor)
        ])
        
        viewController.didMove(toParent: self)
        
        mainVC = viewController
    }
    
    public func setMenuOpened(_ opened: Bool, animated: Bool = true) {
        if opened {
            self.configureMainContentOverlay(forOpenedState: opened)
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0, delay: 0, options: .curveEaseInOut) {
            if opened {
                self.menuSheetPositionConstraint.constant = self.visibleMenuWidth
                self.menuSheet.layer.shadowOpacity = 0.15
                self.mainDimmingOverlay.alpha = 0.25
            } else {
                self.menuSheetPositionConstraint.constant = 0
                self.menuSheet.layer.shadowOpacity = 0
                self.mainDimmingOverlay.alpha = 0
            }
            
            self.view.layoutIfNeeded()
        } completion: { completed in
            self.configureMainContentOverlay(forOpenedState: opened)
        }

    }
    
    @objc private func didTapOutsideMenu() {
        setMenuOpened(false)
    }
    
    private func configureMainContentOverlay(forOpenedState opened: Bool) {
        if opened {
            mainDimmingOverlay.isHidden = false
        } else {
            mainDimmingOverlay.isHidden = true
        }
    }

}

extension UIViewController {
    
    var compactSideMenuContainer: CompactSideMenuContainerViewController? {
        if let container = parent as? CompactSideMenuContainerViewController {
            return container
        } else if parent != nil {
            return parent?.compactSideMenuContainer
        } else {
            return nil
        }
    }
    
}
