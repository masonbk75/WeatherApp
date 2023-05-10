//
//  DetailsFlowController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit
import CoreLocation

class DetailsFlowController: FlowController, NavigatingFlowController {
    
    // MARK: - Properties
    var navigator: UINavigationController

    private var services: ServicesContainer
    private var locationManager: CLLocationManager?
    
    private lazy var detailsViewController: DetailsViewController = {
        let detailsViewController = DetailsViewController()
        detailsViewController.delegate = self
        return detailsViewController
    }()
    
    // MARK: - Initializers
    init(services: ServicesContainer) {
        self.services = services
        locationManager = CLLocationManager()
        navigator = UINavigationController()

        super.init(nibName: nil, bundle: nil)
        
        locationManager?.delegate = self
        add(childController: navigator)

        start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Start
    func start() {
        detailsViewController.configure(with: .init(displayMode: .loading))
        navigator.viewControllers = [detailsViewController]
        switch locationManager?.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .restricted:
            locationManager?.requestLocation()
        default:
            checkSearchHistory()
        }
    }
}

// MARK: - Helpers
private extension DetailsFlowController {
    
    func checkSearchHistory() {
        if let recentSearch = services.searchHistoryService.recentSearches.first {
            let coord: CLLocationCoordinate2D = .init(latitude: recentSearch.lat, longitude: recentSearch.lon)
            fetchWeatherData(with: coord)
        } else {
            detailsViewController.configure(with: .init(displayMode: .firstTime))
        }
    }
    
    func fetchWeatherData(with coordinates: CLLocationCoordinate2D?) {
        guard let coordinates = coordinates else { return }
        services.networkingService.fetchWeatherData(for: coordinates) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let weatherData):
                let recentSearch: RecentSearch = .init(weatherData: weatherData)
                services.searchHistoryService.save(recentSearch)
                configureDetails(with: weatherData)
            case .failure(let error):
                debugPrint(error)
                detailsViewController.configure(with: .init(displayMode: .error(error.localizedDescription)))
            }
        }
    }
    
    func configureDetails(with weatherData: WeatherData) {
        services.iconService.loadImage(named: weatherData.overview.first?.iconName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                detailsViewController.configure(with: .init(displayMode: .details(weatherData, UIImage(data: data))))
            case .failure(let error):
                debugPrint(error)
                detailsViewController.configure(with: .init(displayMode: .error(error.localizedDescription)))
            }
        }
    }
    
    func startSearchFlow() {
        let searchFlowController = SearchFlowController(services: services)
        searchFlowController.delegate = self
        searchFlowController.isModalInPresentation = true
        present(searchFlowController, animated: true)
    }
}

// MARK: - DetailsViewControllerDelegate
extension DetailsFlowController: DetailsViewControllerDelegate {
    
    func detailsViewControllerDidLaunchFirstTime(_: DetailsViewController) {
        let welcomeFlowController = WelcomeFlowController(services: services)
        welcomeFlowController.delegate = self
        welcomeFlowController.isModalInPresentation = true
        present(welcomeFlowController, animated: true)
    }
    
    func detailsViewControllerDidRequestSearch(_: DetailsViewController) {
        startSearchFlow()
    }
}

// MARK: - SearchFlowControllerDelegate
extension DetailsFlowController: SearchFlowControllerDelegate {
    
    func searchFlowController(_ flowController: SearchFlowController, didFetch coordinates: CLLocationCoordinate2D) {
        detailsViewController.configure(with: .init(displayMode: .loading))
        fetchWeatherData(with: coordinates)
        flowController.dismiss(animated: true)
    }
}

// MARK: WelcomeFlowControllerDelegate
extension DetailsFlowController: WelcomeFlowControllerDelegate {
    
    func welcomeFlowController(_ flowController: WelcomeFlowController, didFetch coordinates: CLLocationCoordinate2D) {
        fetchWeatherData(with: coordinates)
        flowController.dismiss(animated: true)
    }
}

extension DetailsFlowController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeatherData(with: location.coordinate)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if case .authorizedWhenInUse = manager.authorizationStatus {
            debugPrint(error.localizedDescription)
            startSearchFlow()
        }
    }
}
