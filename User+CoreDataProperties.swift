//
//  User+CoreDataProperties.swift
//  iBeaconCentralNortification
//
//  Created by MAMORU on 2017/02/13.
//  Copyright © 2017年 PARTY. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var id: NSNumber?
}
