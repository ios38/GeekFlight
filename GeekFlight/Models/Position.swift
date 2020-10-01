//
//  Position.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 01.10.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Position: Decodable {
    var latitude: Double
    var longitude: Double

    init(from json: JSON) {
        latitude = json["lat"].doubleValue
        longitude = json["lon"].doubleValue
    }
}
