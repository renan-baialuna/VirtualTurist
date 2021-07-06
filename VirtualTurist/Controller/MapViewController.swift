//
//  ViewController.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 06/06/21.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    private let reuseIdentifier = "MyIdentifier"
    let segueId = "toLocation"
    var locationChosen: MKPointAnnotation?
    var dataController: DataController!
    var locations: [InternalLocation] = []
    
    let centerLatKey = "centerLat"
    let centerLonKey = "centerLog"
    let spanLatKey = "spanLat"
    let spanLogKey = "spanLog"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMap()
        mapView.delegate = self
        
        let fetchRequest: NSFetchRequest<InternalLocation> = InternalLocation.fetchRequest()
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            locations = results
        }
        getUserDefault()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        let currentLoc = mapView.centerCoordinate
        UserDefaults.standard.setValue(mapView.region.span.latitudeDelta, forKey: spanLatKey)
        UserDefaults.standard.setValue(mapView.region.span.longitudeDelta, forKey: spanLogKey)
        UserDefaults.standard.setValue(currentLoc.latitude, forKey: centerLatKey)
        UserDefaults.standard.setValue(currentLoc.longitude, forKey: centerLonKey)
    }
    
    func getUserDefault() {
        var loc = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        var span = MKCoordinateSpan()
        
        if let latSpan = UserDefaults.standard.value(forKey: spanLatKey) {
//            mapView.region.span.latitudeDelta = latSpan as! CLLocationDegrees
            span.latitudeDelta = latSpan as! CLLocationDegrees
        } else {
            UserDefaults.standard.setValue(mapView.region.span.latitudeDelta, forKey: spanLatKey)
        }
        
        if let lonSpan = UserDefaults.standard.value(forKey: spanLogKey) {
//            mapView.region.span.longitudeDelta = lonSpan as! CLLocationDegrees
            span.longitudeDelta = lonSpan as! CLLocationDegrees
        } else {
            UserDefaults.standard.setValue(mapView.region.span.longitudeDelta, forKey: spanLogKey)
        }
        
        if let latCenter = UserDefaults.standard.value(forKey: centerLatKey) {
            loc.latitude = latCenter as! CLLocationDegrees
        } else {
            UserDefaults.standard.setValue(mapView.region.span.latitudeDelta, forKey: centerLatKey)
        }
        
        if let logCenter = UserDefaults.standard.value(forKey: centerLonKey) {
            loc.longitude = logCenter as! CLLocationDegrees
        } else {
            UserDefaults.standard.setValue(mapView.region.span.latitudeDelta, forKey: centerLonKey)
        }
        
        mapView.setRegion(MKCoordinateRegion(center: loc, span: span), animated: false)
    }
    
    func convertLocation(location: InternalLocation) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        let lat = location.latitude
        let long = location.longitude
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        
        annotation.coordinate = coordinate
        return annotation
    }
    
    func setMap() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:"handleTap:")
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        var annotations: [MKPointAnnotation] = []
        for i in locations {
            let anotation = convertLocation(location: i)
            annotations.append(anotation)
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer){

        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
//        save location
        var internalLocation = InternalLocation(context: dataController.viewContext)
        internalLocation.latitude = Float(coordinate.latitude)
        internalLocation.longitude = Float(coordinate.longitude)
//        try? dataController.viewContext.save()
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = view.annotation as? MKPointAnnotation
        self.locationChosen = location
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            var controller = segue.destination as! LocationViewController
            controller.location = locationChosen!
        }
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    
}
