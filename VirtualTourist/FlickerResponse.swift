//
//  FlickerResponse.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/9/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import Foundation

struct FlickerResponse: Decodable {
    var photos: FlickerResponseData
}

struct FlickerResponseData: Decodable {
    var photos: [FlickerResponsePhoto]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}

struct FlickerResponsePhoto: Decodable {
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
}
