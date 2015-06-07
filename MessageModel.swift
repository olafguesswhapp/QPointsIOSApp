//
//  MessageModel.swift
//  QPointsApp
//
//  Created by Olaf Peters on 05.06.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import Foundation
import CoreData

@objc(MessageModel)
class MessageModel: NSManagedObject {

    @NSManaged var programName: String
    @NSManaged var programCompany: String
    @NSManaged var newsTitle: String
    @NSManaged var newsMessage: String
    @NSManaged var newsDate: NSDate
    @NSManaged var newsStatus: Bool

}
