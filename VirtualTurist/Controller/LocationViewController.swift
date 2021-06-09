//
//  LocationViewController.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 08/06/21.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var location: MKPointAnnotation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        location.title = "Here!"
        mapView.addAnnotation(location)
        let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 1000)!, longitudinalMeters: CLLocationDistance(exactly: 1000)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)    }
   

}
