//
//  Note+CoreDataProperties.swift
//  Argonautes
//
//  Created by KOSUKE SAKURAI on 2025/07/23.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var uuid: UUID?
    @NSManaged public var cursorPosition: Int32
    @NSManaged public var status: Int16
    @NSManaged public var tag: Tag?

}

extension Note : Identifiable {

}
