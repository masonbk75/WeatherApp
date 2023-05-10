//
//  RootFlowController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit

class RootFlowController: FlowController {
    
    // MARK: - Properties
    let services: ServicesContainer
    
    // MARK: - Initializers
    init(services: ServicesContainer) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
        
        configureInitialFlow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Start
    private func configureInitialFlow() {
        add(childController: DetailsFlowController(services: services))
    }
}

