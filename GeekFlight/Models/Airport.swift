//
//  Airport.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 01.10.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class Airport: Decodable {
    var airportFsCode: String
    var coordinate: Coordinate
    var name: String
    var city: String
    
    init(from json: JSON) {
        airportFsCode = json["fs"].stringValue

        let latitude = json["latitude"].doubleValue
        let longitude = json["longitude"].doubleValue
        coordinate = Coordinate(latitude: latitude, longitude: longitude)

        name = json["name"].stringValue
        city = json["city"].stringValue
    }
}
