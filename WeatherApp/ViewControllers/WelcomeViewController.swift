//
//  WelcomeViewController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit

protocol WelcomeViewControllerDelegate: AnyObject {
    func welcomeViewControllerDidRequestStart(_: WelcomeViewController)
}

class WelcomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var headerImageView: UIImageView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var startButton: UIButton!
    
    // MARK: - Properties
    public weak var delegate: WelcomeViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }
}

// MARK: - Helpers
private extension WelcomeViewController {
    
    func configureInterface() {
        headerView.layer.cornerRadius = headerView.frame.width / 2
        startButton.layer.cornerRadius = 15
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        delegate?.welcomeViewControllerDidRequestStart(self)
    }
}
