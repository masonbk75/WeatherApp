//
//  SearchCollectionController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/8/23.
//

import UIKit

protocol SearchCollectionControllerDelegate: AnyObject {
    func searchCollectionControllerDidRequestLocation(_: SearchCollectionController)
    func searchCollectionController(_: SearchCollectionController, didSelect recentSearch: RecentSearch)
}

class SearchCollectionController: NSObject {
    
    // MARK: - Subtypes
    enum Section: Hashable {
        case currentLocation
        case recent
        case newSearch
    }
    
    enum Item: Hashable {
        case currentLocation
        case searchResults(RecentSearch)
    }
    
    // MARK: - Properties
    private let collectionView: UICollectionView
    private var recentSearches: [RecentSearch] = []
    private var newResults: [RecentSearch] = []
    private weak var delegate: SearchCollectionControllerDelegate?
    
    // MARK: - Lazy
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: cellProvider)
    
    private lazy var cellProvider: UICollectionViewDiffableDataSource<Section, Item>.CellProvider = { [weak self] collectionView, indexPath, identifier in
        return self?.cell(for: identifier, indexPath: indexPath, collectionView: collectionView)
    }
    
    private lazy var supplementaryViewProvider: UICollectionViewDiffableDataSource<Section, Item>.SupplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
        return self?.supplementaryView(for: kind, indexPath: indexPath, collectionView: collectionView)
    }
    
    // MARK: - Initializers
    init(collectionView: UICollectionView, delegate: SearchCollectionControllerDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        
        collectionView.delegate = self
        collectionView.collectionViewLayout = collectionViewLayout()
        collectionView.contentInset = .init(top: -25, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - Configurable
extension SearchCollectionController: Configurable {
    
    struct Configuration {
        let recentSearches: [RecentSearch]
        let newResults: [RecentSearch]
    }
    
    func configure(with element: Configuration) {
        recentSearches = element.recentSearches
        newResults = element.newResults
        registerCells()
        configureDataSource()
        dataSource.supplementaryViewProvider = supplementaryViewProvider
    }
}

// MARK: - Helpers
private extension SearchCollectionController {
    
    func registerCells() {
        collectionView.register(UINib(nibName: "SearchResultCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "SearchResultCollectionViewCell")
        collectionView.register(UINib(nibName: "CurrentLocationCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CurrentLocationCollectionViewCell")
        collectionView.register(UINib(nibName: "SearchResultsHeader", bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchResultsHeader")
    }
    
    func configureDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        var sections: [Section] = [.currentLocation]
        if !newResults.isEmpty { sections.append(.newSearch) }
        if !recentSearches.isEmpty { sections.append(.recent) }
        
        snapshot.appendSections(sections)
        snapshot.appendItems([.currentLocation], toSection: .currentLocation)
        
        let newItems: [Item] = newResults.map { .searchResults($0) }
        if !newItems.isEmpty { snapshot.appendItems(newItems, toSection: .newSearch) }
        
        let recentItems: [Item] = recentSearches.map { .searchResults($0) }
        if !recentItems.isEmpty { snapshot.appendItems(recentItems, toSection: .recent) }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension SearchCollectionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .currentLocation:
            delegate?.searchCollectionControllerDidRequestLocation(self)
        case .searchResults(let result):
            delegate?.searchCollectionController(self, didSelect: result)
        }
    }
}

// MARK: - Cell Provider
private extension SearchCollectionController {
    
    func cell(for item: Item, indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        switch item {
        case .currentLocation:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentLocationCollectionViewCell", for: indexPath) as? CurrentLocationCollectionViewCell else { return UICollectionViewCell() }
            return cell
        case .searchResults(let recentSearch):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchResultCollectionViewCell", for: indexPath) as? SearchResultCollectionViewCell else { return UICollectionViewCell() }
            if let state = recentSearch.state {
                cell.configure(with: recentSearch.name + ", " + state)
            } else {
                cell.configure(with: recentSearch.name)
            }
            return cell
        }
    }
    
    func supplementaryView(for kind: String, indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionReusableView? {
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        switch section {
        case .currentLocation:
            return nil
        case .recent:
            let header: SearchResultsHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchResultsHeader", for: indexPath) as! SearchResultsHeader
            header.configure(with: "Recent Searches")
            return header
        case .newSearch:
            let header: SearchResultsHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchResultsHeader", for: indexPath) as! SearchResultsHeader
            header.configure(with: "Results")
            return header
        }
    }
    
    func collectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let hasHeader = self.dataSource.snapshot().sectionIdentifiers[sectionIndex] != .currentLocation
            
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerTopPadding = 0.0
            configuration.headerMode = hasHeader ? .supplementary : .none
            configuration.showsSeparators = hasHeader

            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }

        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        return layout
    }
}
