//
//  ViewController.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 28.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate {
    var mapView = MapView()
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var marker = GMSMarker()
    let dateFormatter = DateFormatter()

    override func loadView() {
        super.loadView()
        self.view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.googleMapView?.delegate = self
        
        configureTrack()
        addMarker()
        let trackingService = TrackingService()
        trackingService.startTrack(icao24: "")
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
    }

    func configureTrack() {
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.strokeColor = .yellow
        route?.strokeWidth = 3
        route?.map = mapView.googleMapView

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation(_:)), name: Notification.Name("TrackingServiceDidUpdateLocation"), object: nil)
        
    }
    
    func addMarker(){
        let marker = GMSMarker()
        marker.map = mapView.googleMapView
        self.marker = marker
    }

    @objc func didUpdateLocation(_ notification: NSNotification) {
        guard let location = notification.userInfo?["location"] as? CLLocation else { return }
        print(location.coordinate)
        self.marker.position = location.coordinate
        self.marker.title = "\(dateFormatter.string(from: location.timestamp))"
        self.marker.snippet = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        let cameraPosition = GMSCameraPosition(target: location.coordinate, zoom: 9)
        self.mapView.googleMapView?.animate(to: cameraPosition)
        routePath?.add(location.coordinate)
        route?.path = routePath
    }

}

