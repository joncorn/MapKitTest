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
  
  
  // MARK: - METHODS
  
  /**
   Converts the placemark to a custom address format like: "4 Melrose Place, Washington DC".
   
   It's not important to know how the above code works. But basically, it adds commas and spaces, even if some of the properties come back as nil.
   For example, it doesn't make sense to split up the string with a comma if the street information is missing.
   */
  func parseAddress(selectedItem:MKPlacemark) -> String {
    // Put a space between "4" and "Melrose Place"
    let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil ) ? " " : ""
    // Put comma between street and city/state
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.subAdministrativeArea != nil) ? ", " : ""
    // Put a space between "Washington" and "DC"
    let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(format: "%@%@%@%@%@%@%@",
                             // Street number
                             selectedItem.subThoroughfare ?? "",
                             firstSpace,
                             // Street name
                             selectedItem.thoroughfare ?? "",
                             comma,
                             // City
                             selectedItem.locality ?? "",
                             secondSpace,
                             // State
                             selectedItem.administrativeArea ?? ""
    )
    return addressLine
  }
  
}


// MARK: - SearchController delegate
extension LocationSearchTable: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    
    // Unwrap the optional values for mapview and the search bar text
    guard let mapView = mapView,
      let searchBarText = searchController.searchBar.text else { return }
    
    // A search request is comprised of a string and a map region
    // We get both from the above unwrapped properties
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchBarText
    request.region = mapView.region
    
    // Performs the actual searhc on the request object
    // Search.start executes the search query and returns a MKLocalSearchResponse object which contains an array of mapitems
    // We stash these mapitems in matchingItems variable above
    let search = MKLocalSearch(request: request)
    search.start { (response, _) in
      guard let response = response else {
        return
      }
      self.matchingItems = response.mapItems
      self.tableView.reloadData()
    }
  }
}

// MARK: - TABLEVIEW DATASOURCE
extension LocationSearchTable {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Array where we store retrieved places determines the number of rows
    return matchingItems.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
    
    // PLacemark is the name of the map item
    let selectedItem = matchingItems[indexPath.row].placemark
    
    cell.textLabel?.text = selectedItem.name
    cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
    
    return cell
  }
}

