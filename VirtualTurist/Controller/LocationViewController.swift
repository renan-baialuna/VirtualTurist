//
//  LocationViewController.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 08/06/21.
//

import UIKit
import MapKit


struct PhotoStruct {
    let id: String
    let image: UIImage?
}

class LocationViewController: UIViewController {

    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var location: MKPointAnnotation!
    var photos: [PhotoStruct] = []
    
    var tempImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
        
        
        
        print("lat \(location.coordinate.latitude)")
        print("lon \(location.coordinate.longitude)")
        
        getUserLocation(lat: Float(location.coordinate.latitude), log: Float(location.coordinate.longitude))
    }
    
    func getUserLocation(lat: Float, log: Float) {
        OTMClient.taskForGetRequest(url: OTMClient.Endpoints.getPhotoListByLocation(lat, log) .url, responseType: PhotoList.self) { (response, error) in
            if error == nil {
                if let response = response {
                    if response.photos.photo.count > 0 {
                        for i in response.photos.photo {
                            self.getPhotoSizes(id: i.id)
                        }
                        
                    } else {
                        print("no photos")
                    }
                }
            } else {
//
            }
        }
    }
    
    func getPhotoSizes(id: String) {
        OTMClient.taskForGetRequest(url: OTMClient.Endpoints.getPhotoAllSizes(id).url,  responseType: PhotoSizes.self) { [self] (response, error) in
            if error == nil {
                if let size = response?.sizes.size {
                    var ret = size[0]
                    for i in size {
                        if i.label == "Medium" {
                            ret = i
                        }
                    }
                    self.getPhoto(id: id, urlString: ret.source)
                }
                
//                print(response?.sizes.size[0].url)
            } else {
//
            }
        }
    }
    
    func getPhoto(id: String, urlString: String) {
        if let url = URL(string: urlString) {

            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                }
                if let safeData = data {
                    if let downloadedImage = UIImage(data: safeData){
//                        self.tempImage = downloadedImage
                        let newPhoto = PhotoStruct(id: id, image: downloadedImage)
                        self.photos.append(newPhoto)
                        DispatchQueue.main.async {
                            self.photosCollection.reloadData()
                        }
                        
                    }
                }
            }
            task.resume()
        }
       
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
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        if let image = photos[indexPath.row].image {
            cell.image.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimensions = (UIScreen.main.bounds.width / 2) - 5
        return CGSize(width: dimensions, height: dimensions)
        
    }
    
}
