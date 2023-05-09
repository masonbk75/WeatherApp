//
//  DetailsViewController.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import UIKit

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
        case details(WeatherData)
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
        case .firstTime: delegate?.detailsViewControllerDidLaunchFirstTime(self)
        case .loading: configureForLoading()
        case .details(let weatherData): configureForDetails(with: weatherData)
        case .error(let message): configureForError(with: message)
        }
    }
    
    func configureForDetails(with weatherData: WeatherData) {
        // maybe add fade animation
        locationLabel.text = weatherData.cityName
        descriptionLabel.text = weatherData.overview.first?.description.capitalized
        currentTempLabel.text = "\(weatherData.mainTemp.temp)°F"
        humidityLabel.text = "\(weatherData.mainTemp.humidity)%"
        feelsLikeLabel.text = "\(weatherData.mainTemp.feelsLike)°F"
    }
    
    func configureForLoading() {
        debugPrint("loading")
    }
    
    func configureForError(with message: String) {
        debugPrint(message)
    }
    
    // MARK: - IBActions
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        delegate?.detailsViewControllerDidRequestSearch(self)
    }
}
