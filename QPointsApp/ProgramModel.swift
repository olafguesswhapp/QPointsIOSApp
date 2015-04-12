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

    @NSManaged var nr: String
    @NSManaged var programName: String
    @NSManaged var programGoal: NSNumber
    @NSManaged var myCount: NSNumber

}
