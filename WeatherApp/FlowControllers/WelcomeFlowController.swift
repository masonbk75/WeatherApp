//
//  WelcomeFlowController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/5/23.
//

import UIKit
import CoreLocation

protocol WelcomeFlowControllerDelegate: AnyObject {
    func welcomeFlowController(_: WelcomeFlowController, didFetch coordinates: CLLocationCoordinate2D)
}

class WelcomeFlowController: FlowController, NavigatingFlowController {
    
    // MARK: - Properties
    var navigator: UINavigationController
    private var locationManager: CLLocationManager?
    private var services: ServicesContainer
    private var isFreshRequest: Bool = false
    
    weak var delegate: WelcomeFlowControllerDelegate?
    
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
    
    func start() {
        let welcomeViewController = WelcomeViewController()
        welcomeViewController.delegate = self
        navigator.viewControllers = [welcomeViewController]
    }
}

// MARK: - Helpers
private extension WelcomeFlowController {
    
    func startSearchFlow() {
        let searchFlowController = SearchFlowController(services: services, isDismissable: false)
        searchFlowController.delegate = self
        navigator.pushViewController(searchFlowController, animated: true)
    }
}

// MARK: - WelcomeViewControllerDelegate
extension WelcomeFlowController: WelcomeViewControllerDelegate {
    
    func welcomeViewControllerDidRequestStart(_: WelcomeViewController) {
        if case .denied = locationManager?.authorizationStatus {
            startSearchFlow()
        } else {
            isFreshRequest = true
            locationManager?.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - SearchFlowControllerDelegate
extension WelcomeFlowController: SearchFlowControllerDelegate {
    
    func searchFlowController(_: SearchFlowController, didFetch coordinates: CLLocationCoordinate2D) {
        delegate?.welcomeFlowController(self, didFetch: coordinates)
    }
}

// MARK: - CLLocationManagerDelegate
extension WelcomeFlowController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        delegate?.welcomeFlowController(self, didFetch: location.coordinate)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager?.requestLocation()
        if case .denied = manager.authorizationStatus, isFreshRequest {
            startSearchFlow()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if case .authorizedWhenInUse = manager.authorizationStatus {
            debugPrint(error.localizedDescription)
            startSearchFlow()
        }
    }
}
