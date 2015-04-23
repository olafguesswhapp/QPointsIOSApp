//
//  ProgramModel.swift
//  QPointsApp
//
//  Created by Olaf Peters on 12.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import Foundation
import CoreData

@objc(ProgramModel)
class ProgramModel: NSManagedObject {

    @NSManaged var programNr: String
    @NSManaged var programName: String
    @NSManaged var programCompany: String
    @NSManaged var programGoal: Int16
    @NSManaged var myCount: Int16
    @NSManaged var programsFinished: Int16
    @NSManaged var programStatus: String
    @NSManaged var programStartDate: NSDate
    @NSManaged var programEndDate: NSDate
    @NSManaged var programKey: String

}
