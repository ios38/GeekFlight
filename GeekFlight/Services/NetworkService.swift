//
//  NetworkService.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 21.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

/*
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
)*/

class NetworkService {
    static let session: Alamofire.Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = Alamofire.Session(configuration: config)
        return session
    }()
    
    static func getAirports(completion: ((Swift.Result<[Airport], Error>) -> Void)? = nil) {
        let baseUrl = "https://api.flightstats.com/flex/airports/rest/v1/json/withinRadius/104.287223/52.287521/150"
        
        let params: Parameters = [
            "appId": "59740609",
            "appKey": "577eb50e53d9ce436a21087f9ff5a6f7",
        ]

        NetworkService.session.request(baseUrl, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(result):
                let json = JSON(result)
                
                let airportsJSONs = json["airports"].arrayValue
                let airports = airportsJSONs.map { Airport(from: $0) }
                
                completion?(.success(airports))
            case let .failure(error):
                completion?(.failure (error))
            }
        }
    }

    static func getFlights(airportFsCode: String, completion: ((Swift.Result<([Airport], [Flight]), Error>) -> Void)? = nil) {
        
        let date = Calendar.current.date(byAdding: .hour, value: -3, to: Date())
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd/HH"
        let formattedDate = format.string(from: date!)
        
        //https://api.flightstats.com/flex/flightstatus/rest/v2/json/airport/status/IKT/dep/2020/10/1/10
        let baseUrl = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/airport/status/" + airportFsCode + "/dep/" + formattedDate
        
        print(baseUrl)

        let params: Parameters = [
            "appId": "69596f57",
            "appKey": "be088250b1c219474c79bce179b30b97",
            "utc": false,
            "numHours": 6,
            "maxFlights": 30
        ]

        NetworkService.session.request(baseUrl, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(result):
                let json = JSON(result)
                //print(json)
                let airportsJSONs = json["appendix"]["airports"].arrayValue
                let airports = airportsJSONs.map { Airport(from: $0) }
                
                let flightsJSONs = json["flightStatuses"].arrayValue
                let flights = flightsJSONs.map { Flight(from: $0) }
                
                completion?(.success((airports, flights)))
            case let .failure(error):
                completion?(.failure (error))
            }
        }
    }

    static func getTrack(flightId: Int, completion: ((Swift.Result<CLLocation, Error>) -> Void)? = nil) {
        let baseUrl = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/track/"
        
        let params: Parameters = [
            "appId": "59740609",
            "appKey": "577eb50e53d9ce436a21087f9ff5a6f7",
            "includeFlightPlan": false,
            "maxPositions": 1
        ]

        NetworkService.session.request(baseUrl + "\(flightId)", method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(result):
                let json = JSON(result)
                let positionsJSONs = json["flightTrack"]["positions"].arrayValue
                //print(positionsJSONs)
                let positions = positionsJSONs.map { Position(from: $0) }
                
                guard let position = positions.first else { return }
                let location = CLLocation(
                    latitude: position.latitude,
                    longitude: position.longitude
                )

                completion?(.success(location))
            case let .failure(error):
                completion?(.failure (error))
            }
        }
    }

    /*
    static func getFlights(completion: ((Swift.Result<[Flight], Error>) -> Void)? = nil) {
        let baseUrl = "http://api.aviationstack.com/v1/flights"
        
        let params: Parameters = [
            "access_key": "c6b56330a21a37cb8e22be491f296963",
            "dep_icao": "UIII"
        ]

        NetworkService.session.request(baseUrl, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(result):
                let json = JSON(result)
                let flightsJSONs = json["data"].arrayValue
                //print(flightsJSONs)
                let flights = flightsJSONs.map { Flight(from: $0) }
                //flights.forEach { flight in
                //    print(flight.flight_icao)
                //}
                completion?(.success(flights))
            case let .failure(error):
                completion?(.failure (error))
            }
        }
    }
    
 static func getFlight(flight_icao: String, completion: ((Swift.Result<Flight, Error>) -> Void)? = nil) {
     let baseUrl = "http://api.aviationstack.com/v1/flights"
     
     let params: Parameters = [
         "access_key": "c6b56330a21a37cb8e22be491f296963",
         //"dep_icao": "UIII",
         "flight_icao": flight_icao
     ]

     NetworkService.session.request(baseUrl, method: .get, parameters: params).responseJSON { response in
         switch response.result {
         case let .success(result):
             let json = JSON(result)
             let flightsJSONs = json["data"].arrayValue
             //print(flightsJSONs)
             let flights = flightsJSONs.map { Flight(from: $0) }
             //print(flights)
             guard let flight = flights.first else { return }
             completion?(.success(flight))
         case let .failure(error):
             completion?(.failure (error))
         }
     }
 }

    static func getLocation(icao24: String, completion: ((Swift.Result<CLLocation, Error>) -> Void)? = nil) {
        let baseUrl = "https://s522es:552253@opensky-network.org/api/states/all"
        
        let params: Parameters = [
            "icao24": "3950c7"
        ]

        NetworkService.session.request(baseUrl, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                let stateJSON = json["states"][0].arrayValue
                //print(stateJSON[5], stateJSON[6])
                //let location = Location(latitude: stateJSON[5].floatValue, longitude: stateJSON[6].floatValue)
                //print(location)
                let location = CLLocation(latitude: stateJSON[5].doubleValue, longitude: stateJSON[6].doubleValue)
                completion?(.success(location))
            case let .failure(error):
                completion?(.failure (error))
            }
        }
    }*/
}
