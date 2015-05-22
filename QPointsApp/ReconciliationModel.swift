//
//  ReconciliationModel.swift
//  QPointsApp
//
//  Created by Olaf Peters on 01.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import Foundation
import CoreData

@objc(ReconciliationModel)
class ReconciliationModel: NSManagedObject {

    @NSManaged var reconType: Int16
    @NSManaged var reconStatus: Bool
    @NSManaged var reconSuccess: Bool
    @NSManaged var reconOptional: String
    @NSManaged var reconUser: String
    @NSManaged var reconProgramNr: String
    @NSManaged var reconProgramGoalToHit: Int16
    @NSManaged var reconQpInput: String
    @NSManaged var reconPassword: String
    @NSManaged var reconGender: Int16
}
