//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewControllerDidCancel(_: SearchViewController)
    func searchViewControllerDidRequestLocation(_: SearchViewController)
    func searchViewController(_: SearchViewController, didSelect recentSearch: RecentSearch)
    func searchViewControllerDidSearch(_: SearchViewController, input: String)
}

class SearchViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var collectionView: UICollectionView!
    
    // MARK: - Properties
    private var configuration: Configuration!
    weak var delegate: SearchViewControllerDelegate?
    
    // MARK: - Lazy
    private lazy var collectionController: SearchCollectionController = .init(collectionView: collectionView, delegate: self)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = configuration.canCancel
        collectionController.configure(with: .init(recentSearches: configuration.recentSearches, newResults: configuration.newResults))
    }
}

// MARK: - Configurable
extension SearchViewController: Configurable {
    
    struct Configuration {
        let canCancel: Bool
        let recentSearches: [RecentSearch]
        let newResults: [RecentSearch]
        let emptySearch: Bool
        
        init(canCancel: Bool, recentSearches: [RecentSearch], newResults: [RecentSearch], emptySearch: Bool = false) {
            self.canCancel = canCancel
            self.recentSearches = recentSearches
            self.newResults = newResults
            self.emptySearch = emptySearch
        }
    }
    
    func configure(with element: Configuration) {
        configuration = element
        guard isViewLoaded else { return }
        searchBar.showsCancelButton = element.canCancel
        collectionController.configure(with: .init(recentSearches: element.recentSearches, newResults: element.newResults, emptySearch: element.emptySearch))
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchViewControllerDidCancel(self)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.searchTextField.text else { return }
        let cleanText = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+")
        delegate?.searchViewControllerDidSearch(self, input: cleanText)
    }
}

// MARK: - SearchCollectionControllerDelegate
extension SearchViewController: SearchCollectionControllerDelegate {
    
    func searchCollectionControllerDidRequestLocation(_: SearchCollectionController) {
        delegate?.searchViewControllerDidRequestLocation(self)
    }
    
    func searchCollectionController(_: SearchCollectionController, didSelect recentSearch: RecentSearch) {
        delegate?.searchViewController(self, didSelect: recentSearch)
    }
}
