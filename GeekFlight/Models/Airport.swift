//
//  Airport.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 01.10.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Airport: Decodable {
    var airportFsCode: String
    var name: String
    var city: String
    
    init(from json: JSON) {
        airportFsCode = json["fs"].stringValue
        name = json["name"].stringValue
        city = json["city"].stringValue
    }
}
