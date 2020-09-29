//
//  NetworkService.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 21.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Location {
    var latitude: Float
    var longitude: Float
}

typealias State = (
    icao24: String,
    callsign: String,
    origin_country: String,
    time_position: Int,
    last_contact: Int,
    longitude: Float,
    latitude: Float,
    baro_altitude: Float,
    on_ground: Bool,
    velocity: Float,
    true_track: Float,
    vertical_rate: Float,
    sensors: Bool,
    geo_altitude: Float,
    squawk: String,
    spi: Bool,
    position_source: Int
)

class NetworkService {
    static let session: Alamofire.Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = Alamofire.Session(configuration: config)
        return session
    }()
    
    static func getLocation(icao24: String, completion: ((Swift.Result<Location, Error>) -> Void)? = nil) {
        let baseUrl = "https://opensky-network.org/api/states/all"
        
        let params: Parameters = [
            "icao24": "4248e6"
        ]

        NetworkService.session.request(baseUrl, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                let stateJSON = json["states"][0].arrayValue
                //print(stateJSON[5], stateJSON[6])
                let location = Location(latitude: stateJSON[5].floatValue, longitude: stateJSON[6].floatValue)
                print(location)
                completion?(.success(location))
            case let .failure(error):
                completion?(.failure (error))
            }
        }
    }
}
