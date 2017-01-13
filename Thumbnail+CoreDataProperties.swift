//
//  Thumbnail+CoreDataProperties.swift
//  Assesment_05
//
//  Created by  shawn on 13/01/2017.
//  Copyright © 2017 shawn. All rights reserved.
//

import Foundation
import CoreData


extension Thumbnail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Thumbnail> {
        return NSFetchRequest<Thumbnail>(entityName: "Thumbnail");
    }

    @NSManaged public var id: Double
    @NSManaged public var imageData: NSData?
    @NSManaged public var photo: Photo?

}
