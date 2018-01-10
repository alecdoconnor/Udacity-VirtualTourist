//
//  Photo.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/6/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import UIKit
import CoreData

extension Photo {
    convenience init(imageURL: URL, image: UIImage? = nil, context: NSManagedObjectContext) {
        self.init(context: context)
        self.imageURL = imageURL
        self.image = image != nil ? UIImagePNGRepresentation(image!) : nil
    }
}
