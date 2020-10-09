//
//  Flight.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 29.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import SwiftyJSON
//import CoreLocation

class Flight: Decodable {
    var flightId: Int
    var departureAirportFsCode: String
    var departureAirportCoordinate: Coordinate?
    var arrivalAirportFsCode: String
    var arrivalAirportCoordinate: Coordinate?
    var departureDateLocal: Date
    var status: String
    
    init(from json: JSON) {
        flightId = json["flightId"].intValue
        departureAirportFsCode = json["departureAirportFsCode"].stringValue
        arrivalAirportFsCode = json["arrivalAirportFsCode"].stringValue

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //"2020-10-01T01:35:00.000Z"
        let dateString = json["departureDate"]["dateLocal"].stringValue
        departureDateLocal = formatter.date(from: dateString) ?? Date()

        status = json["status"].stringValue
    }
    
    //aviationstack.com
    /*
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
    }*/
}
