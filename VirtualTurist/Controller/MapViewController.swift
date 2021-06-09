//
//  ViewController.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 06/06/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    private let reuseIdentifier = "MyIdentifier"
    let segueId = "toLocation"
    var locationChosen: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMap()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setMap() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:"handleTap:")
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
}


extension MapViewController: MKMapViewDelegate {
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer){

        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
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
