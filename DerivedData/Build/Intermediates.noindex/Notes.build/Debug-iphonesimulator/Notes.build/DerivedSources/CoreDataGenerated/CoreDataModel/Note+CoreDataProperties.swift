//
//  Note+CoreDataProperties.swift
//  
//
//  Created by VietDH3.AVI on 1/9/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?

}

extension Note : Identifiable {

}
