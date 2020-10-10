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
    var polylineBehind: GMSPolyline?
    var polylineAhead: GMSPolyline?
    var pathBehind: GMSMutablePath?
    var flightMarker = GMSMarker()
    let dateFormatter = DateFormatter()
    let trackingService = TrackingService()
    var zoom: Float = 8
    var pathAnimationTimer: Timer!
    var pathAnimateSteps = 300
    var markerRotation = 0.0

    internal init(flight: Flight) {
        self.flight = flight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MapController deinitialized")
        trackingService.stopTrack()
        guard let timer = pathAnimationTimer else { return }
        timer.invalidate()
    }
    
    override func loadView() {
        super.loadView()
        self.view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.googleMapView?.delegate = self
        mapView.zoomLabel.text = "Zoom: \(zoom)"

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")

        configureTrack()
        configureMarker()

        getEarlyTrack()
        //getEarlyTrackSimple()
        //trackingService.startTrack(flightId: flight.flightId)
    }

    func configureTrack() {
        pathBehind = GMSMutablePath()

        polylineBehind?.map = nil
        polylineBehind = GMSPolyline()
        polylineBehind?.strokeColor = .green
        polylineBehind?.strokeWidth = 2
        polylineBehind?.geodesic = true
        polylineBehind?.map = mapView.googleMapView

        polylineAhead?.map = nil
        polylineAhead = GMSPolyline()
        polylineAhead?.strokeColor = .yellow
        polylineAhead?.strokeWidth = 1
        polylineAhead?.geodesic = true
        polylineAhead?.map = mapView.googleMapView

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation(_:)), name: Notification.Name("TrackingServiceDidUpdateLocation"), object: nil)
    }
    
    func configureMarker(){
        let departureMarker = GMSMarker()
        departureMarker.title = "\(flight.departureAirportFsCode)"
        //departureMarker.snippet = "\(flight.departureAirportFsCode)"
        if let departureCoordinate = flight.departureAirportCoordinate?.locationCoordinate() {
            departureMarker.position = departureCoordinate
            departureMarker.map = mapView.googleMapView
        }
        
        let arrivalMarker = GMSMarker()
        arrivalMarker.title = "\(flight.arrivalAirportFsCode)"
        //arrivalMarker.snippet = "\(flight.arrivalAirportFsCode)"
        if let arrivalCoordinate = flight.arrivalAirportCoordinate?.locationCoordinate() {
            arrivalMarker.position = arrivalCoordinate
            arrivalMarker.map = mapView.googleMapView
        }

        let marker = GMSMarker()
        marker.iconView = MarkerView()
        marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        marker.map = mapView.googleMapView
        self.flightMarker = marker
    }
    
    func getEarlyTrackSimple() {
        NetworkService.getTrack(flightId: flight.flightId, count: 2) { result in
            switch result {
            case .success(let locations):
                guard let locations = locations["flightLocations"],
                      let from = locations.last?.coordinate,
                      let to = locations.first?.coordinate,
                      let departureCoordinate = self.flight.departureAirportCoordinate?.locationCoordinate(),
                      let rotation = CLLocationDegrees(exactly: self.getHeadingForDirection(from: from, to: to))
                else { return }
                
                self.pathBehind?.add(departureCoordinate)
                self.pathBehind?.add(from)
                self.markerRotation = rotation + 90
                self.flightMarker.rotation = self.markerRotation
                let cameraPosition = GMSCameraPosition(target: from, zoom: self.zoom)
                self.mapView.googleMapView?.animate(to: cameraPosition)
                self.animatePath(from: from, to: to)
                self.trackingService.startTrack(flightId: self.flight.flightId)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    
    func getEarlyTrack() { //get multipositions early track
        NetworkService.getTrack(flightId: flight.flightId, count: 600) { result in
            switch result {
            case .success(let locations):
                guard var locations = locations["flightLocations"],
                          locations.count >= 2
                else { return }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"

                locations.forEach { location in
                    print("\(formatter.string(from: location.timestamp)) \(location.coordinate.latitude) \(location.coordinate.longitude)")
                }
                
                let from = locations[1].coordinate
                let to = locations[0].coordinate

                if locations.count == 2 {
                    self.animatePath(from: from, to: to)
                } else if locations.count > 2 {
                    locations.remove(at: 0)
                    //for i in 0..<10 {
                    //    locations.remove(at: i)
                    //}
                    locations.reversed().forEach { location in
                        self.pathBehind?.add(location.coordinate)
                    }
                    self.polylineBehind?.path = self.pathBehind
                    
                    let rotation = CLLocationDegrees(exactly: self.getHeadingForDirection(from: from, to: to))!
                    self.markerRotation = rotation + 90
                    self.flightMarker.rotation = self.markerRotation
                    let cameraPosition = GMSCameraPosition(target: from, zoom: self.zoom)
                    self.mapView.googleMapView?.animate(to: cameraPosition)

                    self.animatePath(from: from, to: to)
                    self.trackingService.startTrack(flightId: self.flight.flightId)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func didUpdateLocation(_ notification: NSNotification) {
        guard let locations = notification.userInfo?["flightLocations"] as? [CLLocation],
              let from = locations.last?.coordinate,
              let to = locations.first?.coordinate,
              let rotation = CLLocationDegrees(exactly: getHeadingForDirection(from: from, to: to))
              //let rotation = CLLocationDegrees(exactly: getDirection(from: from, to: to))
        else { return }
        print("from: \(from) to \(to)")
        //self.marker.position = from
        markerRotation = rotation + 90
        print("markerRotation: \(markerRotation)")
        flightMarker.rotation = markerRotation
        //self.marker.title = "\(dateFormatter.string(from: location.timestamp))"
        //self.marker.snippet = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        let cameraPosition = GMSCameraPosition(target: from, zoom: zoom)
        mapView.googleMapView?.animate(to: cameraPosition)
        animatePath(from: from, to: to)
    }
    
    func animatePath(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        let path = makePath(from: from, to: to)
        //let pathAhead = GMSMutablePath()
        
        if let arrivalCoordinate = flight.arrivalAirportCoordinate?.locationCoordinate() {
            let pathAhead = makePath(from: from, to: arrivalCoordinate)
            self.polylineAhead?.path = pathAhead
        }
        
        if pathAnimationTimer != nil {
            pathAnimationTimer.invalidate()
        }
        
        var index: UInt = 0
        let count = path.count() - 1
        let timeInterval: TimeInterval = 60.0 / Double(path.count())
        
        self.pathBehind?.add(path.coordinate(at: index))
        self.polylineBehind?.path = self.pathBehind
        self.flightMarker.position = path.coordinate(at: index)
        
        pathAnimationTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] timer in
            index += 1
            if index <= count {
                let coordinate = path.coordinate(at: index)
                if let arrivalCoordinate = self?.flight.arrivalAirportCoordinate?.locationCoordinate() {
                    let pathAhead = self?.makePath(from: coordinate, to: arrivalCoordinate)
                    self?.polylineAhead?.path = pathAhead
                }
                self?.pathBehind?.add(coordinate)
                //print("\(index): \(path.coordinate(at: index))")
                self?.polylineBehind?.path = self?.pathBehind
                self?.flightMarker.position = path.coordinate(at: index)
            } else {
                timer.invalidate()
            }
        }
    }
    
    func makePath(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> GMSMutablePath {
        let path = GMSMutablePath()
        path.add(from)
        
        let latitudeDelta = (to.latitude - from.latitude) / Double(self.pathAnimateSteps)
        let longitudeDelta = (to.longitude - from.longitude) / Double(self.pathAnimateSteps)
        
        var latitude = from.latitude
        var longitude = from.longitude
        
        for _ in 1..<pathAnimateSteps {
            latitude += latitudeDelta
            longitude += longitudeDelta
            //print("\(i): \(latitude), \(longitude)")
            path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        return path
    }

    func getHeadingForDirection(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Float {
        let fromLat: Float = Float((from.latitude).degreesToRadians)
        let fromLng: Float = Float((from.longitude).degreesToRadians)
        let toLat: Float = Float((to.latitude).degreesToRadians)
        let toLng: Float = Float((to.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(toLng - fromLng) * cos(toLat), cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(toLng - fromLng))).radiansToDegrees
        if degree >= 0 {
            return degree - 180.0
        }
        else {
            return (360 + degree) - 180
        }
    }

    func getDirection(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let a = to.latitude - from.latitude
        let b = to.longitude - from.longitude
        let tangent = a / b
        return atan(tangent) * 180 / Double.pi
    }
    
    //MARK: - GMSMapViewDelegate

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        zoom = mapView.camera.zoom
        let bearing = mapView.camera.bearing
        //print("bearing: \(bearing)")
        flightMarker.rotation = markerRotation - bearing
        self.mapView.zoomLabel.text = "Zoom: \(zoom)"
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
