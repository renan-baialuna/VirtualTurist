//
//  LocationViewController.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 08/06/21.
//

import UIKit
import MapKit
import CoreData


struct PhotoStruct {
    let id: String
    let image: UIImage?
}

class LocationViewController: UIViewController {

    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var location: MKPointAnnotation!
    var dataController: DataController!
    var internalLocation: InternalLocation!
    var photos: [PhotoStruct] = []
    var photosSelected: [String] = []
    var hasDataSaved: Bool = true
    var numberofPhotos: Int = 0
    var numberOfLoadedPhotos: Int = 0
    var photosLoaded: [PhotoStruct] = []
    var photosToPresente: [PhotoStruct] = []
    
    var internalPhotos: [InternalPhoto] = []
    var tempImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
        let fetchRequest: NSFetchRequest<InternalPhoto> = InternalPhoto.fetchRequest()
        let predicate  = NSPredicate(format: "location == %@", internalLocation)
        fetchRequest.predicate = predicate
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            
            if result.count > 0 {
                self.internalPhotos = result
            } else {
                getUserLocation(lat: Float(location.coordinate.latitude), log: Float(location.coordinate.longitude))
                hasDataSaved = false
            }
            
            
            getInternalPhotos()
        } else {
            getUserLocation(lat: Float(location.coordinate.latitude), log: Float(location.coordinate.longitude))
        }
        
        
    }
    
    func getInternalPhotos() {
        for i in self.internalPhotos {
            let newPhoto = PhotoStruct(id: i.id!, image: UIImage(data: i.image!))
            self.photos.append(newPhoto)
            self.photosToPresente = self.photos
        }
        DispatchQueue.main.async {
            self.photosCollection.reloadData()
        }
    }
    
    func getUserLocation(lat: Float, log: Float) {
        OTMClient.taskForGetRequest(url: OTMClient.Endpoints.getPhotoListByLocation(lat, log) .url, responseType: PhotoList.self) { (response, error) in
            if error == nil {
                if let response = response {
                    if response.photos.photo.count > 0 {
                        self.numberofPhotos = response.photos.photo.count
                        for i in response.photos.photo {
                            self.getPhotoSizes(id: i.id)
                        }
                        
                    } else {
                        self.showAlert()
                        print("no photos")
                    }
                }
            } else {
                self.showAlert()
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
                        self.numberOfLoadedPhotos += 1
                        let newPhoto = PhotoStruct(id: id, image: downloadedImage)
                        self.photosToPresente = self.addNewPhotoToCollection(newPhoto)
                        DispatchQueue.main.async {
                            self.photosCollection.reloadData()
                        }
                        
                    }
                }
            }
            task.resume()
        }
       
    }
    
    func addNewPhotoToCollection(_ newPhoto: PhotoStruct) -> [PhotoStruct] {
        var ret: [PhotoStruct] = []
        photosLoaded.append(newPhoto)
        ret = photosLoaded
        var totalOfMockPhotos = numberofPhotos - numberOfLoadedPhotos
        while totalOfMockPhotos > 0 {
            ret.append(PhotoStruct(id: "0", image: UIImage(named: "photoLoading")))
            totalOfMockPhotos -= 1
        }
        
        return ret
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
        return photosToPresente.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        if let image = photosToPresente[indexPath.row].image {
            cell.image.image = image
        }
        
        if searchPhoto(photosToPresente[indexPath.row].id) {
            cell.backgroundColor = .black
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimensions = (UIScreen.main.bounds.width / 2) - 5
        return CGSize(width: dimensions, height: dimensions)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var internalPhoto = InternalPhoto(context: dataController.viewContext)
        let cell = photosToPresente[indexPath.row]
        if !searchPhoto(cell.id) && !hasDataSaved {
            internalPhoto.id = cell.id
            internalPhoto.image = cell.image?.pngData()
            internalPhoto.location = internalLocation
            self.photosSelected.append(internalPhoto.id!)
            
            try? dataController.viewContext.save()
            collectionView.reloadData()
        }
    }
    
    
    
    func searchPhoto(_ id: String) -> Bool {
        for i in photosSelected {
            if i == id {
                return true
            }
        }
        return false
    }
    
    func showAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "No Photos found", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
