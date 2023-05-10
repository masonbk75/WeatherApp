//
//  DetailsViewController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit
import SwiftUI

protocol DetailsViewControllerDelegate: AnyObject {
    func detailsViewControllerDidLaunchFirstTime(_: DetailsViewController)
    func detailsViewControllerDidRequestSearch(_: DetailsViewController)
}

class DetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var currentTempLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var feelsLikeLabel: UILabel!
    @IBOutlet private var cloudCoverageView: UIView!
    @IBOutlet private var humiditydView: UIView!
    @IBOutlet private var searchButton: UIButton!
    @IBOutlet private var detailViews: [UIView]!
    
    // MARK: - Properties
    private var displayMode: DisplayMode = .loading
    weak var delegate: DetailsViewControllerDelegate?
    
    // MARK: - Lifesycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureInterface()
    }
}

// MARK: - Configurable
extension DetailsViewController: Configurable {
    
    enum DisplayMode {
        case firstTime
        case loading
        case details(WeatherData, UIImage?)
        case error(String)
    }
    
    struct Configuration {
        let displayMode: DisplayMode
    }
    
    func configure(with element: Configuration) {
        displayMode = element.displayMode
        
        guard isViewLoaded else { return }
        configureInterface()
    }
}

// MARK: - Helpers
private extension DetailsViewController {
    
    func configureInterface() {
        switch displayMode {
        case .firstTime:
            hideAllViews()
            delegate?.detailsViewControllerDidLaunchFirstTime(self)
        case .loading: configureForLoading()
        case .details(let weatherData, let image): configureForDetails(with: weatherData, image: image)
        case .error(let message): configureForError(with: message)
        }
    }
    
    func configureForDetails(with weatherData: WeatherData, image: UIImage?) {
        imageView.image = image
        imageView.layer.cornerRadius = imageView.frame.height / 2
        locationLabel.text = weatherData.cityName
        descriptionLabel.text = weatherData.overview.first?.description.capitalized
        currentTempLabel.text = "\(weatherData.mainTemp.temp)°F"
        humidityLabel.text = "\(weatherData.mainTemp.humidity)%"
        feelsLikeLabel.text = "\(weatherData.mainTemp.feelsLike)°F"
        configureCloudView(cloudCoverage: weatherData.clouds)
        configureHumidityView(humidity: weatherData.mainTemp.humidity)
        
        detailViews.forEach { view in
            view.alpha = 1
        }
    }
    
    func configureCloudView(cloudCoverage: Clouds) {
        cloudCoverageView.subviews.forEach({ $0.removeFromSuperview() })
        let cloudView = PercentageView(displayType: .clouds, percentage: cloudCoverage.all)
        guard let hostView = UIHostingController(rootView: cloudView).view else { return }
        hostView.translatesAutoresizingMaskIntoConstraints = false
        cloudCoverageView.addSubview(hostView)
        hostView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: cloudCoverageView.topAnchor),
            hostView.bottomAnchor.constraint(equalTo: cloudCoverageView.bottomAnchor),
            hostView.leadingAnchor.constraint(equalTo: cloudCoverageView.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: cloudCoverageView.trailingAnchor)
        ])
    }
    
    func configureHumidityView(humidity: Double) {
        humiditydView.subviews.forEach({ $0.removeFromSuperview() })
        let humidityPercentView = PercentageView(displayType: .humidity, percentage: humidity)
        guard let hostView = UIHostingController(rootView: humidityPercentView).view else { return }
        hostView.translatesAutoresizingMaskIntoConstraints = false
        humiditydView.addSubview(hostView)
        hostView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: humiditydView.topAnchor),
            hostView.bottomAnchor.constraint(equalTo: humiditydView.bottomAnchor),
            hostView.leadingAnchor.constraint(equalTo: humiditydView.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: humiditydView.trailingAnchor)
        ])
    }
    
    func configureForLoading() {
        // Given more time, I would add a loading animation
        descriptionLabel.text = "Loading"
        hideAllViews()
    }
    
    func configureForError(with message: String) {
        debugPrint(message)
        descriptionLabel.text = "Error please try another search"
        hideAllViews(shouldShowSearch: true)
    }
    
    func hideAllViews(shouldShowSearch: Bool = false) {
        detailViews.forEach { view in
            view.alpha = 0
        }
        if shouldShowSearch {
            searchButton.alpha = 1
        }
    }
    
    // MARK: - IBActions
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        delegate?.detailsViewControllerDidRequestSearch(self)
    }
}
