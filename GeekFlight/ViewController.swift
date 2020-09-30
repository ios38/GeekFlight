//
//  ViewController.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 28.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var flightsView = FlightsView()
    var flights = [Flight]()

    override func loadView() {
        super.loadView()
        self.view = flightsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.flightsView.tableView.dataSource = self
        self.flightsView.tableView.delegate = self

        NetworkService.getFlights() { result in
            switch result {
            case .success(let flights):
                self.flights = flights
                self.flightsView.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "FlightCell")
        let flight = flights[indexPath.row]
        cell.textLabel?.text = "\(flight.arrivalAirport) \(flight.date) \(flight.status)"
        cell.detailTextLabel?.text = "\(flight.latitude)"
        return cell
    }
    
    //MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let fligth = flights[indexPath.row]
        print(fligth.flight_icao)
        let trackingService = TrackingService()
        trackingService.startTrack(flight_icao: fligth.flight_icao)

        //let mapController = MapController(flight: fligth)
        //self.navigationController?.pushViewController(mapController, animated: true)

    }

}

