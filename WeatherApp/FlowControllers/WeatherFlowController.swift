//
//  WeatherFlowController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit
import CoreLocation

class WeatherFlowController: FlowController, NavigatingFlowController {
    
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
private extension WeatherFlowController {
    
    func checkSearchHistory() {
        let hasSearchHistory = false
        if hasSearchHistory {
            // do something
        } else {
            detailsViewController.configure(with: .init(displayMode: .firstTime))
        }
    }
    
    func configureDetails(with coordinates: CLLocationCoordinate2D?) {
        guard let coordinates = coordinates else { return }
        services.networkingService.fetchWeatherData(for: coordinates) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let weatherData):
                let recentSearch: RecentSearch = .init(weatherData: weatherData)
                services.searchHistoryService.save(recentSearch)
                detailsViewController.configure(with: .init(displayMode: .details(weatherData)))
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
extension WeatherFlowController: DetailsViewControllerDelegate {
    
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
extension WeatherFlowController: SearchFlowControllerDelegate {
    
    func searchFlowController(_ flowController: SearchFlowController, didFetch coordinates: CLLocationCoordinate2D) {
        configureDetails(with: coordinates)
        flowController.dismiss(animated: true)
    }
}

// MARK: WelcomeFlowControllerDelegate
extension WeatherFlowController: WelcomeFlowControllerDelegate {
    
    func welcomeFlowController(_ flowController: WelcomeFlowController, didFetch coordinates: CLLocationCoordinate2D) {
        configureDetails(with: coordinates)
        flowController.dismiss(animated: true)
    }
}

extension WeatherFlowController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        configureDetails(with: location.coordinate)
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
