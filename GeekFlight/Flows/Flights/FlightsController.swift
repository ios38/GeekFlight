//
//  ViewController.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 28.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import UIKit
import GoogleMaps

class FlightsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let navigationItemTitle = "Рейсы"
    var airportFsCode = ""
    var flightsView = FlightsView()
    var flights = [Flight]()
    var airports = [Airport]()
    lazy var trackingService = TrackingService()

    override func loadView() {
        super.loadView()
        self.view = flightsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = navigationItemTitle
        self.flightsView.tableView.dataSource = self
        self.flightsView.tableView.delegate = self

        NetworkService.getFlights(airportFsCode: airportFsCode) { result in
            switch result {
            case .success(let (airports, flights)):
                self.airports = (airports, flights).0
                self.flights = (airports, flights).1
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FlightCell")
        let flight = flights[indexPath.row]
        let airport = airports.first { $0.airportFsCode == flight.arrivalAirportFsCode }
        cell.textLabel?.text = "\(airport?.city ?? "") \(flight.arrivalAirportFsCode)"
        cell.detailTextLabel?.text = "\(flight.departureDateLocal) Status: \(flight.status)"
        return cell
    }
    
    //MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //trackingService.stopTrack()
        tableView.deselectRow(at: indexPath, animated: true)
        let flight = flights[indexPath.row]
        print("did select flightId \(flight.flightId)")
        let mapController = MapController(flight: flight)
        self.navigationController?.pushViewController(mapController, animated: true)

    }

}

