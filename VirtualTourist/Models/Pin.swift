//
//  Pin.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/6/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import MapKit
import CoreData

extension Pin {
    convenience init(coordinate: CLLocationCoordinate2D, title: String = "", context: NSManagedObjectContext) {
        self.init(context: context)
        self.longitude = coordinate.longitude
        self.latitude = coordinate.latitude
        self.title = title
    }
}

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latitudeDegrees = CLLocationDegrees(latitude)
        let longitudeDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latitudeDegrees, longitude: longitudeDegrees)
    }
}
