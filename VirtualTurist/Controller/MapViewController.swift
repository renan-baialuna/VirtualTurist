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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMap()
        mapView.delegate = self
        
        let fetchRequest: NSFetchRequest<InternalLocation> = InternalLocation.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "", ascending: <#T##Bool#>)
//        fetchRequest.sortDescriptors = []
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            locations = results
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        try? dataController.viewContext.save()
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = view.annotation as? MKPointAnnotation
        self.locationChosen = location
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            var controller = segue.destination as! LocationViewController
//            controller.location = locationChosen!
        }
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    
}
