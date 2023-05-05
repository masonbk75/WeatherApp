//
//  Configurable.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/5/23.
//

import Foundation

public protocol Configurable {
    associatedtype ConfiguringType
    
    /// Configures `Self` with `element`.
    func configure(with element: ConfiguringType)
}
