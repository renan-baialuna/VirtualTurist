//
//  OTMClient.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 10/06/21.
//

import Foundation

class OTMClient {
    
    struct Auth {
        static var apiKey: String = "f9cc014fa76b098f9e82f1c288379ea1"
    }
    
    
    enum Endpoints  {
        case getPhotoListByLocation(Float, Float)
        case getPhotoAllSizes(String)
        
        var stringValue: String {
            switch self {
            case .getPhotoListByLocation(let lat, let log):
                return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=f9cc014fa76b098f9e82f1c288379ea1&per_page=10&lat=\(lat)&lon=\(log)&format=json&nojsoncallback=1"
            case .getPhotoAllSizes(let id):
                return "https://www.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=f9cc014fa76b098f9e82f1c288379ea1&photo_id=\(id)&format=json&nojsoncallback=1"
                
            }
//            https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=f9cc014fa76b098f9e82f1c288379ea1&lat=-23.493383994940075&lon=-46.64572056038642&per_page=10&format=json&nojsoncallback=1
                
        }
        var url: URL {
            print(stringValue)
            return URL(string: stringValue)!
        }
    }
    
    
    
    
    
    
    
    
    @discardableResult class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping(ResponseType?, Error?) -> Void) -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                var responseObject: ResponseType
                responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
         return task
    }
    
}
