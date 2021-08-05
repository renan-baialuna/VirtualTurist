//
//  OTMClient.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 10/06/21.
//

import Foundation

class OTMClient {
    
    struct Auth {
        static var apiKey: String = "8a359454596806b82de4db34e515d9b9"
    }
    
    
    enum Endpoints  {
        case getPhotoListByLocation(Float, Float, Int)
        case getPhotoAllSizes(String)
        
        var stringValue: String {
            switch self {
            case .getPhotoListByLocation(let lat, let log, let page):
                return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.apiKey)&per_page=10&page=\(page)&lat=\(lat)&lon=\(log)&format=json&nojsoncallback=1"
            case .getPhotoAllSizes(let id):
                return "https://www.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=\(Auth.apiKey)&photo_id=\(id)&format=json&nojsoncallback=1"
                
            }
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
