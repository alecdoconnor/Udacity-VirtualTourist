//
//  FlickerGrabber.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/9/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import Foundation

class FlickerGrabber {
    
    private var baseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1"
    private let authKey = "eb2465c83afa11a7771c10c2856a8bb6"
    
    private let session = URLSession.shared
    
    let photoLimit = 12
    
    init() {
        baseURL += "&api_key=\(authKey)"
    }
    
    // URL Methods
    
    private func urlForImageByLocation(lat: Double, lon: Double) -> String {
        return "\(baseURL)&lat=\(lat)&lon=\(lon)"
    }
    
    func getURLFromResponse(response: FlickerResponsePhoto) -> URL {
        let urlString = "https://farm\(response.farm).staticflickr.com/\(response.server)/\(response.id)_\(response.secret)_n.jpg"
        return URL(string: urlString)!
    }
    
    // Network Requests
    
    func getImageURLs(lat: Double, lon: Double, callback: @escaping (([URL]?, String?) -> Void)) {
        let urlString = urlForImageByLocation(lat: lat, lon: lon)
        let url = URL(string: urlString)!
        let task = session.dataTask(with: url) { (data, _, error) in
            guard let data = data else {
                callback(nil, "\(String(describing: error))")
                return
            }
            do {
                let response = try JSONDecoder().decode(FlickerResponse.self, from: data)
                var photos = response.photos.photos.map { self.getURLFromResponse(response: $0) }
                print("\(photos.count) photos found on flicker")
                if photos.count > self.photoLimit {
                    photos = photos.getRandomValues(limit: self.photoLimit)
                }
                callback(photos, nil)
            } catch {
                print(String(data: data, encoding: .utf8))
                print("Error: \n\(error)")
                callback(nil, "Unable to parse response: \n\(String(describing: String(data: data, encoding: .utf8)))")
            }
        }
        task.resume()
    }
    
}
