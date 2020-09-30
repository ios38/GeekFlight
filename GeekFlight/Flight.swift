//
//  Flight.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 29.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class Flight: Decodable {
    
    var date: String
    var status: String
    var departureAirport: String
    var arrivalAirport: String
    var flight_icao: String
    var latitude: Double
    var longitude: Double

    internal init(date: String, status: String, departureAirport: String, arrivalAirport: String, flight_icao: String, latitude: Double, longitude: Double) {
        self.date = date
        self.status = status
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.flight_icao = flight_icao
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from json: JSON) {
        date = json["flight_date"].stringValue
        status = json["flight_status"].stringValue
        departureAirport = json["departure"]["airport"].stringValue
        arrivalAirport = json["arrival"]["airport"].stringValue
        flight_icao = json["flight"]["icao"].stringValue
        latitude = json["live"]["latitude"].doubleValue
        longitude = json["live"]["longitude"].doubleValue
    }
}
