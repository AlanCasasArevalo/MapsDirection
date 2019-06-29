//
//  ViewController.swift
//  MapsDirection
//
//  Created by Alan Casas on 28/06/2019.
//  Copyright © 2019 Alan Casas. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON


enum Location {
    case startLocation
    case destinationLocation
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var startLocationTextField: UITextField!
    @IBOutlet weak var destinationLocationTextField: UITextField!
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    let autocompleteViewController = GMSAutocompleteViewController()
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setLocationManager()
        setGoogleMap()
    }
    
    func setDelegates () {
        self.mapView.delegate = self
        locationManager.delegate = self
        autocompleteViewController.delegate = self
    }
    
    func setLocationManager () {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func addGestureToTextField() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSomething))
        tap.numberOfTapsRequired = 2
        
        self.startLocationTextField.addGestureRecognizer(tap)
        self.destinationLocationTextField.addGestureRecognizer(tap)
    }
    
    @objc func openSomething (){
        
    }
    
    func setGoogleMap() {
        let camera = GMSCameraPosition(latitude: 40.486564, longitude: -3.661996, zoom: 15.0)
        
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.zoomGestures = true
    }
    
    @IBAction func showDirectionButton(_ sender: Any) {
        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
    }
    
    @IBAction func startLocationButton(_ sender: Any) {
        locationSelected = .startLocation
        UISearchBar.appearance().tintColor = UIColor.blue
        self.locationManager.stopUpdatingLocation()
        self.present(autocompleteViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func endDestinationButton(_ sender: Any) {
        locationSelected = .destinationLocation
        UISearchBar.appearance().tintColor = UIColor.blue
        self.locationManager.stopUpdatingLocation()
        self.present(autocompleteViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func goToGoogleMaps(_ sender: Any) {
        
        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(locationStart.coordinate.latitude),\(locationEnd.coordinate.longitude)&directionsmode=driving")!
        
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://?saddr=&daddr=\(locationStart.coordinate.latitude),\(locationEnd.coordinate.longitude)&directionsmode=driving")!) {
            UIApplication.shared.open(url, options: [:])

        }
        
    }
        
    func createMarker (titleMarker: String, iconMarkerString: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees  ) {
        let marker = GMSMarker()
        let latitude = latitude
        let longitude = longitude
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = titleMarker
        marker.icon = UIImage(named: iconMarkerString)
        marker.map = mapView
    }
    
}

extension ViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error to get location: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }else if  CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController(title: "Danos permiso", message:  "Sin permiso no podemos usar la aplicacion", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else if CLLocationManager.authorizationStatus() == .authorizedAlways{
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let fuenlaLocation = CLLocation(latitude: 40.2973313, longitude: -3.8295479)
        let everisLocation = CLLocation(latitude: 40.486564, longitude: -3.661996)
        createMarker(titleMarker: "Fuenlabrada", iconMarkerString: "001-people", latitude: fuenlaLocation.coordinate.latitude, longitude: fuenlaLocation.coordinate.longitude)
        createMarker(titleMarker: "Everis", iconMarkerString: "002-meal", latitude: everisLocation.coordinate.latitude, longitude: everisLocation.coordinate.longitude)
        createMarker(titleMarker: "Everis", iconMarkerString: "002-meal", latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        //        drawPath(startLocation: fuenlaLocation, endLocation: everisLocation)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.isMyLocationEnabled = true
        if gesture {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Coordenadas \(coordinate)")
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }
    
    func drawPath( startLocation: CLLocation, endLocation: CLLocation) {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyBEQyb0dKvhFDAsKfjlJx1JR989yKvzKcY"
        
        Alamofire.request(url).responseJSON { (response) in
            
            print(response.request)
            print(response.response)
            print(response.data)
            print(response.result)
            
            let json = try? JSON(data: response.data!)
            
            let routes = json!["routes"].arrayValue
            
            for route in routes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline!["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.mapView
            }
            
        }
    }
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let camera = GMSCameraPosition(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0)
        
        if locationSelected == .startLocation {
            startLocationTextField.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            createMarker(titleMarker: "Location Start", iconMarkerString: "002-meal", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
        } else {
            destinationLocationTextField.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            createMarker(titleMarker: "Location Start", iconMarkerString: "002-meal", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        self.mapView.camera = camera
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    
}
























