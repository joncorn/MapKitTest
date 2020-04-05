//
//  LocationSearchTable.swift
//  mapstest
//
//  Created by Jon Corn on 4/4/20.
//  Copyright © 2020 Jon Corn. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
  
  // MARK: - PROPERTIES
  
  // Stashes search results for easy access
  var matchingItems: [MKMapItem] = []
  
  // mapView is a handle to the map from the previous screen
  // Search queries rely on a map region to prioritize local results
  var mapView: MKMapView? = nil
  
}

// MARK: - SearchController delegate
extension LocationSearchTable: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
  }
}

