//
//  AirportsController.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 01.10.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import UIKit

class AirportsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var airportsView = AirportsView()
    let navigationItemTitle = "Аэропорты"
    var airports = [Airport]()
    
    override func loadView() {
        super.loadView()
        self.view = airportsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = navigationItemTitle
        self.airportsView.tableView.dataSource = self
        self.airportsView.tableView.delegate = self
        getAirports()
    }

    func getAirports() {
        NetworkService.getAirports { result in
            switch result {
            case .success(let airports):
                self.airports = airports
                self.airportsView.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AirportCell")
        cell.textLabel?.text = airports[indexPath.row].city
        cell.detailTextLabel?.text = airports[indexPath.row].name
        return cell

    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let airportFsCode = airports[indexPath.row].airportFsCode
        let flightsController = FlightsController()
        flightsController.airportFsCode = airportFsCode
        self.navigationController?.pushViewController(flightsController, animated: true)
    }

}
