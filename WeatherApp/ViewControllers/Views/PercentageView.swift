//
//  PercentageView.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/9/23.
//

import SwiftUI

struct PercentageView: View {
    
    // MARK: - Subtype
    enum DisplayType {
        case clouds
        case humidity
        
        var title: String {
            switch self {
            case .clouds: return "Cloud coverage"
            case .humidity: return "Humidity"
            }
        }
        
        var color: Color {
            switch self {
            case .clouds: return .blue
            case .humidity: return .red
            }
        }
    }
    
    // MARK: - Properties
    var displayType: DisplayType
    var percentage: Double
       
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    let center = CGPoint(x: width * 0.5, y: height * 0.5)
                    
                    path.move(to: center)
                    path.addArc(center: center,
                                radius: width * 0.5,
                                startAngle: Angle(degrees: -90.0),
                                endAngle: Angle(degrees: -90.0) + Angle(degrees: (percentage / 100) * 360),
                                clockwise: false)
                }
                .fill(displayType.color)
                
                Circle()
                    .fill(.white)
                    .frame(width: geometry.size.width * 0.75)
                    .shadow(radius: 5)
                VStack {
                    Text(String(format: "%.0f", percentage) + "%")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(displayType.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct CloudCoverageView_Previews: PreviewProvider {
    static var previews: some View {
        PercentageView(displayType: .clouds, percentage: 90)
    }
}
