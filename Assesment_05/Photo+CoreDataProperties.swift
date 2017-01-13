//
//  Photo+CoreDataProperties.swift
//  Assesment_05
//
//  Created by  shawn on 13/01/2017.
//  Copyright © 2017 shawn. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var fileName: String?
    @NSManaged public var directory1: String?
    @NSManaged public var directory2: String?
    @NSManaged public var directory3: String?
    @NSManaged public var directory4: String?
    @NSManaged public var photoImage: NSData?
    @NSManaged public var photoDescription: String?
    @NSManaged public var directory5: String?
    @NSManaged public var directory6: String?
    @NSManaged public var thumbnail: Thumbnail?

}
