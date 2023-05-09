//
//  SearchFlowController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/8/23.
//

import UIKit
import CoreLocation

protocol SearchFlowControllerDelegate: AnyObject {
    func searchFlowController(_: SearchFlowController, didFetch coordinates: CLLocationCoordinate2D)
}

class SearchFlowController: FlowController {
    
    // MARK: - Properties
    private var locationManager: CLLocationManager?
    private var services: ServicesContainer
    private var isDismissable: Bool
    private var recentSearches: [RecentSearch] = []
    private var newResults: [RecentSearch] = []
    
    weak var delegate: SearchFlowControllerDelegate?
    
    private lazy var searchViewController: SearchViewController = {
        let searchViewController = SearchViewController()
        searchViewController.delegate = self
        return searchViewController
    }()
        
    // MARK: - Initializers
    init(services: ServicesContainer, isDismissable: Bool = true) {
        self.services = services
        self.isDismissable = isDismissable
        locationManager = CLLocationManager()
        
        super.init(nibName: nil, bundle: nil)
        
        locationManager?.delegate = self
        recentSearches = services.searchHistoryService.recentSearches

        start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        searchViewController.configure(with: .init(canCancel: isDismissable, recentSearches: recentSearches, newResults: newResults))
        add(childController: searchViewController)
    }
}

// MARK: - Helpers
private extension SearchFlowController {
    
}

// MARK: - SearchViewControllerDelegate
extension SearchFlowController: SearchViewControllerDelegate {
    
    func searchViewControllerDidCancel(_: SearchViewController) {
        dismiss(animated: true)
    }
    
    func searchViewControllerDidRequestLocation(_: SearchViewController) {
        locationManager?.requestLocation()
    }
    
    func searchViewController(_: SearchViewController, didSelect recentSearch: RecentSearch) {
        let coord: CLLocationCoordinate2D = .init(latitude: recentSearch.lat, longitude: recentSearch.lon)
        delegate?.searchFlowController(self, didFetch: coord)
    }
    
    func searchViewControllerDidSearch(_: SearchViewController, input: String) {
        services.networkingService.fetchCoordinates(for: input) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                debugPrint(response)
                self.newResults = response
                searchViewController.configure(with: .init(canCancel: self.isDismissable, recentSearches: self.recentSearches, newResults: self.newResults))
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension SearchFlowController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return } // handle this failure
        delegate?.searchFlowController(self, didFetch: location.coordinate)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
}
