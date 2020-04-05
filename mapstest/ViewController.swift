//
//  ViewController.swift
//  mapstest
//
//  Created by Jon Corn on 4/4/20.
//  Copyright © 2020 Jon Corn. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
  func dropPinZoomIn(placemark: MKPlacemark)
}

class ViewController: UIViewController {
  
  // MARK: - PROPERTIES
  let locationManager = CLLocationManager()
  var resultSearchController: UISearchController? = nil
  
  // Using this to cache any incoming placemarks
  var selectedPin: MKPlacemark? = nil
  
  // MARK: - OUTLETS
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: - VIEW LIFECYCLE
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    
    setupLocationManager()
    setupSearchBar()
  }
  
  // MARK: - METHODS
  func setupLocationManager() {
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
  }
  
  func setupSearchBar() {
    
    // Points to our tableview controller to displace the search results
    let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
    resultSearchController = UISearchController(searchResultsController: locationSearchTable)
    resultSearchController?.searchResultsUpdater = locationSearchTable
    
    // Configures search bar and embeds it within the nav bar
    let searchBar = resultSearchController!.searchBar
    searchBar.sizeToFit()
    searchBar.placeholder = "Search for places"
    navigationItem.titleView = resultSearchController?.searchBar
    
    // Configure UISearchController appearance
    resultSearchController?.hidesNavigationBarDuringPresentation = false
    definesPresentationContext = true
    
    // Passes along a handle of the mapView from the main view controller onto the locationsearchtable
    locationSearchTable.mapView = mapView
    
    // Deprecated vvv
    // resultSearchController?.dimsBackgroundDuringPresentation = true
  }
  
}

// MARK: - CLLOCATION MANAGER DELEGATE
extension ViewController: CLLocationManagerDelegate {
  
  // Gets called when the user responds to the permission dialog
  // If the user chose Allow, the status becomes CLAuthorizationStatus.AuthorizedWhenInUse
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse {
      locationManager.requestLocation()
    }
  }
  
  // Gets called when location information comes back, you get an array of locations, but you're only interested in the first item
  // Eventually, you will zoom in on this location
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      print("location: \(location)")
      
      // span is the "frame" W x H of the map
      let span = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
      let region = MKCoordinateRegion(center: location.coordinate, span: span)
      mapView.setRegion(region, animated: true)
    }
  }
  
  // Print error
  // Necessary function, with it, app with crash
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error: \(error)")
  }
}

// MARK: - HANDLE MAP SEARCH

/// Implements the dropPinZoomIn() method in order to adopt the HandleMapSearch protocol
extension ViewController: HandleMapSearch {
  func dropPinZoomIn(placemark: MKPlacemark) {
    // Cache the pin
    selectedPin = placemark
    // Clear existing pins
    mapView.removeAnnotations(mapView.annotations)
    
    // Creates the message box above the pin
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    // With title
    annotation.title = placemark.name
    if let city = placemark.locality, let state = placemark.administrativeArea {
      // With Subtitle
      annotation.subtitle = "\(city) \(state)"
    }
    mapView.addAnnotation(annotation)
    let span = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
    let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
    mapView.setRegion(region, animated: true)
  }
  
  
}
