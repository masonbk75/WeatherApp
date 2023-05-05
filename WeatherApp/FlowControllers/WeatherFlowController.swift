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
    private var weatherData: WeatherData?
    
    // MARK: - Initializers
    init(services: ServicesContainer) {
        self.services = services
        locationManager = CLLocationManager()
        navigator = UINavigationController()

        super.init(nibName: nil, bundle: nil)
        
        add(childController: navigator)
        locationManager?.delegate = self
        locationManager?.requestLocation()

        start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Start
    func start() {
        switch locationManager?.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .restricted, .denied:
            configureForReturningUser()
        case .none, .notDetermined:
            configureWelcomeViewController()
        @unknown default:
            configureWelcomeViewController()
        }
    }
}

// MARK: - Helpers
private extension WeatherFlowController {
    
    func configureWelcomeViewController() {
        let welcomeViewController = WelcomeViewController()
        welcomeViewController.delegate = self
        navigator.viewControllers = [welcomeViewController]
    }
    
    func configureForReturningUser() {
        
    }
    
    func fetchWeatherData(for location: CLLocation) {
        let coordinates = location.coordinate
        services.networkingService.fetchWeatherData(for: coordinates) { result in
            switch result {
            case .success(let weatherData):
                self.weatherData = weatherData
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}

// MARK: - WelcomeViewControllerDelegate
extension WeatherFlowController: WelcomeViewControllerDelegate {
    
    func welcomeViewControllerDidRequestStart(_: WelcomeViewController) {
        locationManager?.requestWhenInUseAuthorization()
    }
}

extension WeatherFlowController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            fetchWeatherData(for: location)
        } else {
            // go to search
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            debugPrint("not determined")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager?.requestLocation()
        @unknown default:
            debugPrint("unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // go to search
    }
}
