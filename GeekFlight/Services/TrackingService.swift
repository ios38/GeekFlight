//
//  TrackingService.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 28.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import Foundation
import CoreLocation

class TrackingService {
    var timer: Timer?
    var trackInterval: TimeInterval = 60

    //flightstats.com
    func startTrack(flightId: Int) {
        //first position
        getTrack(flightId: flightId)
        //following positions
        timer = Timer.scheduledTimer(withTimeInterval: trackInterval, repeats: true, block: { _ in
            self.getTrack(flightId: flightId)
        })
    }
    
    private func getTrack(flightId: Int) {
        NetworkService.getTrack(flightId: flightId) { result in
            switch result {
            case .success(let locations):
                print("\(flightId): \(locations["flightLocation"]!.coordinate.latitude), \(locations["flightLocation"]!.coordinate.longitude)")
                //let locationDict:[String: CLLocation] = ["location": location]
                NotificationCenter.default.post(name: NSNotification.Name("TrackingServiceDidUpdateLocation"), object: nil, userInfo: locations)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func stopTrack() {
        guard let timer = timer else { return }
        timer.invalidate()
    }
    
    /* //aviationstack.com
    func startTrack(flight_icao: String) {
        
        timer = Timer.scheduledTimer(withTimeInterval: trackInterval, repeats: true, block: { _ in
            NetworkService.getFlight(flight_icao: flight_icao) { result in
                switch result {
                case .success(let flight):
                    print("\(flight.longitude), \(flight.latitude), \(flight.status)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
    }*/

    /* //opensky-network.org
    func startTrack(icao24: String) {
        
        NetworkService.getLocation(icao24: "") { result in
            switch result {
            case .success(let location):
                //print(location.coordinate)
                let locationDict:[String: CLLocation] = ["location": location]
                NotificationCenter.default.post(name: NSNotification.Name("TrackingServiceDidUpdateLocation"), object: nil, userInfo: locationDict)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: trackInterval, repeats: true, block: { _ in
            NetworkService.getLocation(icao24: "") { result in
                switch result {
                case .success(let location):
                    //print(location.coordinate)
                    let locationDict:[String: CLLocation] = ["location": location]
                    NotificationCenter.default.post(name: NSNotification.Name("TrackingServiceDidUpdateLocation"), object: nil, userInfo: locationDict)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
    }*/
}
