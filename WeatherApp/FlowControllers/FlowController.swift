//
//  FlowController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit

class FlowController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Helpers
    public func add(childController: UIViewController) {
        addChild(childController)
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    public func remove(childController: UIViewController) {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}
