//
//  SidebarViewController.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import Combine
import DeviceControl
import UIKit

class SidebarViewController: UIViewController, UICollectionViewDelegate {
    
    private var metadataStore: DeviceMetadataStore
    private var observations = Set<AnyCancellable>()
        
    init(metadataStore: DeviceMetadataStore) {
        self.metadataStore = metadataStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!
    
    weak var delegate: SidebarDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
        
        metadataStore.$devices
            .sink { devices in
                self.applySnapshot(devices: devices)
            }
            .store(in: &observations)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = true
            configuration.headerMode = .none
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, indexPath, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
            contentConfiguration.text = item.title
            contentConfiguration.image = item.image
            
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
        }
    }
    
    private func applySnapshot(devices: [DeviceMetadata]) {
        var snapshot = NSDiffableDataSourceSnapshot<SidebarSection, SidebarItem>()
        
        if !devices.isEmpty {
            snapshot.appendSections([.devices])
            
            let items: [SidebarItem] = metadataStore.devices.enumerated().map {
                .row(title: $0.element.nickname, image: nil, row: .device(index: $0.offset))
            }
            
            snapshot.appendItems(items, toSection: .devices)
        }
        
        if metadataStore.devices.count < 10 {
            snapshot.appendSections([.addDevice])
            snapshot.appendItems([
                .row(title: "Add Controller", image: .init(systemName: "plus.circle"), row: .addDevice)
            ], toSection: .addDevice)
        }
        
        snapshot.appendSections([.info])
        snapshot.appendItems([
            .row(title: "FAQ", image: .init(systemName: "questionmark.circle"), row: .faq),
            .row(title: "Contact Us", image: .init(systemName: "envelope"), row: .contactUs),
            .row(title: "About", image: .init(systemName: "info.circle"), row: .about)
        ], toSection: .info)
        
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.sidebarItemSelected(sidebarItem.row)
    }

}
