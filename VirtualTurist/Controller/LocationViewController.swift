//
//  LocationViewController.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 08/06/21.
//

import UIKit
import MapKit
import CoreData


class PhotoStruct {
    let id: String
    var image: UIImage?
    var isSelected: Bool
    
    init(id: String, image: UIImage?, isSelected: Bool = false) {
        self.id = id
        self.image = image
        self.isSelected = isSelected
    }
}

struct SearchResult {
    let found:Bool
    let position: Int?
}

class LocationViewController: UIViewController {

    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var button: UIButton!
    var location: MKPointAnnotation!
    var dataController: DataController!
    var internalLocation: InternalLocation!
    var photosSelected: [String] = []
    var hasDataSaved: Bool = true
    var numberOfPhotosToLoad: Int = 0
    var pagesLoadedTotal: Int = 0
    var photosToPresente: [PhotoStruct] = []
    var internalPhotos: [InternalPhoto] = []
    var tempImage: UIImage?
    var page: Int = 1
    var totalPages: Int = 0
    
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
            let newPhoto = PhotoStruct(id: i.id!, image: UIImage(data: i.image!), isSelected: true)
            self.photosToPresente.append(newPhoto)
        }
        DispatchQueue.main.async {
            self.photosCollection.reloadData()
        }
    }
    
    func getUserLocation(lat: Float, log: Float) {
        if totalPages > 0 {
            self.page = Int.random(in: 1...totalPages)
        } else {
            self.page = 1
        }
        OTMClient.taskForGetRequest(url: OTMClient.Endpoints.getPhotoListByLocation(lat, log, self.page) .url, responseType: PhotoList.self) { (response, error) in
            if error == nil {
                if let response = response {
                    self.totalPages = response.photos.pages
                    if response.photos.photo.count > 0 {
                        for i in response.photos.photo {
                            if !self.searchPhotoEnhanced(i.id).found {
                                self.numberOfPhotosToLoad += 1
                                self.addUpdatePhoto(id: i.id)
                                self.getPhotoSizes(id: i.id)
                            }
                        }
                    } else {
                        if self.photosToPresente.count == 0 {
                            self.showAlert()
                            print("no photos")
                        }
                        
                    }
                }
            } else {
                self.showAlert()
            }
        }
    }
    
    func getPhotoSizes(id: String) {
        OTMClient.taskForGetRequest(url: OTMClient.Endpoints.getPhotoAllSizes(id).url,  responseType: PhotoSizes.self) { [self] (response, error) in
            self.numberOfPhotosToLoad -= 1
            self.pagesLoadedTotal += 1
            DispatchQueue.main.async {
                self.button.isEnabled = self.numberOfPhotosToLoad <= 0
            }
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
                    if let downloadedImage = UIImage(data: safeData) {
                        self.addUpdatePhoto(id: id, image: downloadedImage)
                        DispatchQueue.main.async {
                            self.photosCollection.reloadData()
                        }
                    }
                }
            }
            task.resume()
        }
       
    }
    
    func addUpdatePhoto(id: String, image: UIImage = UIImage(named: "photoLoading")!) {
        let searchResult = searchPhotoEnhanced(id)
        if searchResult.found {
            photosToPresente[searchResult.position!].image = image
        } else {
            let newPhoto = PhotoStruct(id: id, image: image)
            self.photosToPresente.append(newPhoto)
        }
    }

    
    @IBAction func starNewCollection() {
        let fetchRequest: NSFetchRequest<InternalPhoto> = InternalPhoto.fetchRequest()
        let predicate  = NSPredicate(format: "location == %@", internalLocation)
        fetchRequest.predicate = predicate
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            for i in result {
                dataController.viewContext.delete(i)
            }
            try? dataController.viewContext.save()
        }
        photosToPresente = []
        getUserLocation(lat: Float(location.coordinate.latitude), log: Float(location.coordinate.longitude))
        photosCollection.reloadData()
        
        
    }
    
    
    
    func searchPhotoEnhanced(_ id: String) -> SearchResult {
        var index = 0
        for i in photosToPresente {
            if i.id == id {
                return SearchResult(found: true, position: index)
            }
            index += 1
        }
        return SearchResult(found: false, position: nil)
    }
    
    
    func setupLocation() {
        location.title = "Here!"
        mapView.addAnnotation(location)
        let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 1000)!, longitudinalMeters: CLLocationDistance(exactly: 1000)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
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


extension LocationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosToPresente.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = photosToPresente[indexPath.row]
        
        if let image = photo.image {
            cell.image.image = image
        }
        
        if photo.isSelected {
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
        let selectedPhoto = photosToPresente[indexPath.row]
        if selectedPhoto.isSelected {
            selectedPhoto.isSelected = false
            
            let fetchRequest: NSFetchRequest<InternalPhoto> = InternalPhoto.fetchRequest()
            let predicate  = NSPredicate(format: "id == %@", selectedPhoto.id)
            fetchRequest.predicate = predicate
            
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                for i in result {
                    dataController.viewContext.delete(i)
                }
                try? dataController.viewContext.save()
            }
            photosToPresente.remove(at: indexPath.row)
            
        } else {
            selectedPhoto.isSelected = true
            var internalPhoto = InternalPhoto(context: dataController.viewContext)
            let cell = photosToPresente[indexPath.row]
            internalPhoto.id = cell.id
            internalPhoto.image = cell.image?.pngData()
            internalPhoto.location = internalLocation
            
            try? dataController.viewContext.save()
            
            
        }
        collectionView.reloadData()
    }
    
    
}
