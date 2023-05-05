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
    
    weak var delegate: WelcomeFlowControllerDelegate?
    
    // MARK: - Initializers
    init(services: ServicesContainer, locationManager: CLLocationManager?) {
        self.services = services
        self.locationManager = locationManager
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

// MARK: - WelcomeViewControllerDelegate
extension WelcomeFlowController: WelcomeViewControllerDelegate {
    
    func welcomeViewControllerDidRequestStart(_: WelcomeViewController) {
        locationManager?.requestWhenInUseAuthorization()
    }
}

extension WelcomeFlowController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            delegate?.welcomeFlowController(self, didFetch: location.coordinate)
        } else {
            // go to search
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if case .authorizedWhenInUse = manager.authorizationStatus {
            locationManager?.requestLocation()
        } else {
            //go to search
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // go to search
    }
}
