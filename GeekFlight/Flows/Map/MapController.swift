//
//  MapController.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 29.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController, GMSMapViewDelegate {
    var mapView = MapView()
    var flight: Flight
    var polyline: GMSPolyline?
    var path: GMSMutablePath?
    var marker = GMSMarker()
    let dateFormatter = DateFormatter()
    let trackingService = TrackingService()
    var zoom: Float = 8
    var pathAnimationTimer: Timer!

    internal init(flight: Flight) {
        self.flight = flight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        trackingService.stopTrack()
        pathAnimationTimer.invalidate()
        print("MapController deinitialized")
    }
    
    override func loadView() {
        super.loadView()
        self.view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.googleMapView?.delegate = self
        mapView.zoomLabel.text = "Zoom: \(zoom)"
        
        configureTrack()
        configureMarker()
        trackingService.startTrack(flightId: flight.flightId)

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
    }

    func configureTrack() {
        polyline?.map = nil
        polyline = GMSPolyline()
        path = GMSMutablePath()
        polyline?.strokeColor = .yellow
        polyline?.strokeWidth = 3
        polyline?.map = mapView.googleMapView

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation(_:)), name: Notification.Name("TrackingServiceDidUpdateLocation"), object: nil)
    }
    
    func configureMarker(){
        let marker = GMSMarker()
        marker.iconView = MarkerView()

        marker.map = mapView.googleMapView
        self.marker = marker
    }

    @objc func didUpdateLocation(_ notification: NSNotification) {
        guard let locations = notification.userInfo?["flightLocations"] as? [CLLocation],
              let from = locations.last?.coordinate,
              let to = locations.first?.coordinate
        else { return }
        print("from: \(from) to \(to)")
        self.marker.position = from
        //self.marker.title = "\(dateFormatter.string(from: location.timestamp))"
        //self.marker.snippet = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        let cameraPosition = GMSCameraPosition(target: from, zoom: zoom)
        self.mapView.googleMapView?.animate(to: cameraPosition)
        self.animatePath(path: self.makePath(from: from, to: to, count: 300))
    }
    
    func animatePath(path: GMSMutablePath) {
        if pathAnimationTimer != nil {
            pathAnimationTimer.invalidate()
        }
        var index: UInt = 0
        let count = path.count() - 1
        let timeInterval: TimeInterval = 60.0 / Double(path.count())
        
        self.path?.add(path.coordinate(at: index))
        self.polyline?.path = self.path
        pathAnimationTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] timer in
            index += 1
            if index <= count {
                self?.path?.add(path.coordinate(at: index))
                //print("\(index): \(path.coordinate(at: index))")
                self?.polyline?.path = self?.path
            } else {
                timer.invalidate()
            }
        }
    }
    
    func makePath(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, count: Int) -> GMSMutablePath {
        let path = GMSMutablePath()
        path.add(from)
        
        let latitudeDelta = (to.latitude - from.latitude) / Double(count)
        let longitudeDelta = (to.longitude - from.longitude) / Double(count)
        
        var latitude = from.latitude
        var longitude = from.longitude
        
        for i in 1..<count {
            latitude += latitudeDelta
            longitude += longitudeDelta
            print("\(i): \(latitude), \(longitude)")
            path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        return path
    }

    //MARK: - GMSMapViewDelegate

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        zoom = mapView.camera.zoom
        self.mapView.zoomLabel.text = "Zoom: \(zoom)"
    }
}
