//
//  Coordinate.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 07.10.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import CoreLocation

struct Coordinate: Decodable {
    let latitude: Double
    let longitude: Double

    func locationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
