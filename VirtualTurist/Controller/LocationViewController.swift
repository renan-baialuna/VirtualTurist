//
//  LocationViewController.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 08/06/21.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {

    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var location: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        photosCollection.delegate = self
        photosCollection.dataSource = self
    }
    
    func setupLocation() {
        location.title = "Here!"
        mapView.addAnnotation(location)
        let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 1000)!, longitudinalMeters: CLLocationDistance(exactly: 1000)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
}


extension LocationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimensions = (UIScreen.main.bounds.width / 2) - 5
        return CGSize(width: dimensions, height: dimensions)
        
    }
    
}
