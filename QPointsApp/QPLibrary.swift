//
//  QPLibrary.swift
//  QPointsApp
//
//  Created by Olaf Peters on 03.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController {
    
    // put a new ScanCode or RedeemCode Task firt into ReconciliationList (delete the Task after reconciliation with webserver)
    func setReconciliationList(setRecLiType:Int16,setRecLiUser: String,setRecLiProgNr: String,setRecLiGoalToHit: Int16, setRecLiQPCode: String)->ReconciliationModel {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("ReconciliationModel", inManagedObjectContext: managedObjectContext!)
        let reconTask = ReconciliationModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        // Set reconTask Values
        reconTask.reconStatus = false // always false when firstly created
        reconTask.reconType = setRecLiType
        reconTask.reconUser = setRecLiUser
        reconTask.reconProgramNr = setRecLiProgNr
        reconTask.reconProgramGoalToHit = setRecLiGoalToHit
        reconTask.reconQpInput = setRecLiQPCode
        // values currently not available:
        reconTask.reconSuccess = false
        reconTask.reconMessage = ""
        println("Reconciliation-Type \(reconTask.reconType) with ScanCode \(reconTask.reconQpInput) or ProgramNr \(reconTask.reconProgramNr)")
        appDelegate.saveContext()
        return reconTask
    }
    
    func deleteReconTask(reconTask: ReconciliationModel)->Void{
        var context:NSManagedObjectContext = reconTask.managedObjectContext!
        context.deleteObject(reconTask)
        var savingError: NSError?
        if context.save(&savingError){
            println("Successfully deleted the Reconciliation Task")
        } else {
            if let error = savingError{
                println("Failed to delete the Reconciliation Task. Error = \(error)")
            }
        }
    }
    
    func APIPostRequest(reconTask: ReconciliationModel, apiType: Int16, completionHandler2: (apiMessage: String) -> Void) {
        // Prepare API Post request
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicodecheck")!)
        var params = [
            "user" : reconTask.reconUser,
            "qpInput" : ""
        ]
        switch apiType {
        case 1:
            params = [
                "user" : reconTask.reconUser,
                "qpInput" : reconTask.reconQpInput
            ]
        case 2:
            request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicoderedeem")!)
            params = [
                "user" : reconTask.reconUser,
                "programNr" : reconTask.reconProgramNr,
                "programGoal" : String(reconTask.reconProgramGoalToHit)
            ]
        default:
            request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/api")!)
        }
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // API Post request
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary!)
            completionHandler2(apiMessage: jsonDictionary!["message"]! as String)
            self.deleteReconTask(reconTask) // CHECK OB WIRKLICH IMMER RECON GELÖSCHT WERDEN SOLL
            if apiType==1 {
                self.processResponseScannedCode(jsonDictionary!)
            }
        })
        task.resume()
    }
    
    func processResponseScannedCode (jsonDictionary: NSDictionary)->Void{
        // handle API response only if code is valid - success = true
        if jsonDictionary["success"]! as Bool == true {
            var isNewProgram: Bool = true
            // prepare core data comparison
            let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("ProgramModel", inManagedObjectContext: managedObjectContext!)
            let fetchRequest = NSFetchRequest(entityName: "ProgramModel")
            if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProgramModel] {
                var index: Int
                // run through all already avaiable Programes and check if new code is part of one of those Programes
                for index = 0; index<fetchResults.count; ++index{
                    if fetchResults[index].programNr == jsonDictionary["nr"]! as String {
                        // code belongs to an already available Program
                        isNewProgram = false
                        fetchResults[index].myCount += 1 // Increase Code Counter
                        // Check if latest Code completes Goal
                        if fetchResults[index].myCount == fetchResults[index].programGoal {
                            fetchResults[index].myCount = 0
                            fetchResults[index].programsFinished += 1
                        }
                        println("Counter: \(fetchResults[index].myCount) and finished \(fetchResults[index].programsFinished)")
                        appDelegate.saveContext()
                    }
                }
            }
            println(isNewProgram)
            if isNewProgram == true {
                // new Code is 1st scanned code of a new Programe - import information from Programe and save in core data
                let program = ProgramModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                program.programNr = jsonDictionary["nr"]! as String
                program.programName = jsonDictionary["name"]! as String
                program.programCompany = jsonDictionary["company"]! as String
                var helpInt: Int = jsonDictionary["goalToHit"]! as Int
                program.programGoal = Int16(helpInt)
                program.myCount = 1
                program.programStatus = jsonDictionary["programStatus"]! as String
                program.programKey = jsonDictionary["key"]! as String
                let dateFormatter: NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"
                program.programStartDate = dateFormatter.dateFromString(jsonDictionary["startDate"]! as String)!
                program.programEndDate = dateFormatter.dateFromString(jsonDictionary["endDate"]! as String)!
                println(program.programStartDate)
                println(program.programEndDate)
                appDelegate.saveContext()
                println(program)
            }
        }
    }
}
