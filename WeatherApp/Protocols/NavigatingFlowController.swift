//
//  NavigatingFlowController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit

protocol NavigatingFlowController: AnyObject {
    var navigator: UINavigationController { get set }
    func start()
}
