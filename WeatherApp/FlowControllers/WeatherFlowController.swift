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
        guard let coordinates = coordinates else { return } // go to search flow
        services.networkingService.fetchWeatherData(for: coordinates) { [weak self] result in
            guard let self = self else { return } // go to search
            switch result {
            case .success(let weatherData):
                detailsViewController.configure(with: .init(displayMode: .details(weatherData)))
            case .failure(let error):
                debugPrint(error)
                // go to search
            }
        }
    }
}

// MARK: - DetailsViewControllerDelegate
extension WeatherFlowController: DetailsViewControllerDelegate {
    
    func detailsViewControllerDidLaunchFirstTime(_: DetailsViewController) {
        let welcomeFlowController = WelcomeFlowController(services: services, locationManager: locationManager)
        welcomeFlowController.delegate = self
        welcomeFlowController.isModalInPresentation = true
        present(welcomeFlowController, animated: true)
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
        if let location = locations.first {
            // save these coordinates 
            configureDetails(with: location.coordinate)
        } else {
            // go to search
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // go to search
    }
}
