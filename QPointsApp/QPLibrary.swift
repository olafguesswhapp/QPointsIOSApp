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
    func setReconciliationList(setRecLiType:Int16,setRecLiUser: String,setRecLiProgNr: String,setRecLiGoalToHit: Int16, setRecLiQPCode: String, setRecLiPW: String, setRecLiGender: Int16)->ReconciliationModel {
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
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
        reconTask.reconPassword = setRecLiPW
        reconTask.reconGender = setRecLiGender
        // values currently not available:
        reconTask.reconSuccess = false
        reconTask.reconOptional = ""
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
    
    func deleteProgramData(responseData: NSDictionary)->Void{
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("ProgramModel", inManagedObjectContext: managedObjectContext!)
        let fetchRequest = NSFetchRequest(entityName: "ProgramModel")
        fetchRequest.includesPropertyValues = false
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProgramModel]{
            for result in fetchResults {
                managedObjectContext?.deleteObject(result)
            }
        }
        var savingError: NSError?
        if managedObjectContext!.save(&savingError){
            println("Successfully deleted the entities in Program Model")
        } else {
            if let error = savingError{
                println("Failed to delete the entities in Program Model . Error = \(error)")
            }
        }
        if (responseData.objectForKey("programData") != nil) {
            self.importProgramData(responseData)
        }
    }
    
    func APIPostRequest(reconTask: ReconciliationModel, apiType: Int16, completionHandler2: (responseDict: NSDictionary) -> Void) {
        // Prepare API Post request
        var request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/apicodecheck")!)
        var params = [
            "userEmail" : reconTask.reconUser,
            "qpInput" : ""
        ]
        switch apiType {
        case 1:
            params = [
                "userEmail" : reconTask.reconUser,
                "qpInput" : reconTask.reconQpInput
            ]
        case 2:
            request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/apicoderedeem")!)
            params = [
                "userEmail" : reconTask.reconUser,
                "programNr" : reconTask.reconProgramNr,
                "programGoal" : String(reconTask.reconProgramGoalToHit)
            ]
        case 3:
            request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/apicheckuser")!)
            params = [
                "userEmail" : reconTask.reconUser,
                "password" : reconTask.reconPassword
            ]
        case 4:
            request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/apicreateaccount")!)
            params = [
                "userEmail" : reconTask.reconUser,
                "password" : reconTask.reconPassword
            ]
        case 5:
            request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/apiupdateuser")!)
            params = [
                "userEmail" : reconTask.reconUser,
                "passwordOld" : reconTask.reconPassword,
                "passwordNew" :reconTask.reconQpInput,
                "gender" : String(reconTask.reconGender)
            ]
        case 6:
            request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/apinewsfeed")!)
            params = [
                "userEmail" : reconTask.reconUser,
                "password" : reconTask.reconPassword
            ]
        default:
            request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/api")!)
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
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &conversionError) as? NSDictionary
            if jsonDictionary != nil {
                completionHandler2(responseDict: jsonDictionary!)
                if apiType==1 {
                    self.processResponseScannedCode(jsonDictionary!)
                }
                if apiType == 6 {
                    self.importNewsData(jsonDictionary!)
                }
                self.deleteReconTask(reconTask) // CHECK OB WIRKLICH IMMER RECON GELÖSCHT WERDEN SOLL
            }
        })
        task.resume()
    }
    
    func processResponseScannedCode (jsonDictionary: NSDictionary)->Void{
        // handle API response only if code is valid - success = true
        if jsonDictionary["success"]! as! Bool == true {
            var isNewProgram: Bool = true
            // prepare core data comparison
            let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("ProgramModel", inManagedObjectContext: managedObjectContext!)
            let fetchRequest = NSFetchRequest(entityName: "ProgramModel")
            if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProgramModel] {
                var index: Int
                // run through all already avaiable Programes and check if new code is part of one of those Programes
                for index = 0; index<fetchResults.count; ++index{
                    if fetchResults[index].programNr == jsonDictionary["nr"]! as! String {
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
            if isNewProgram == true {
                // new Code is 1st scanned code of a new Programe - import information from Programe and save in core data
                let program = ProgramModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                program.programNr = jsonDictionary["nr"]! as! String
                program.programName = jsonDictionary["name"]! as! String
                program.programCompany = jsonDictionary["company"]! as! String
                var helpInt: Int = jsonDictionary["goalToHit"]! as! Int
                program.programGoal = Int16(helpInt)
                program.myCount = 1
                program.programStatus = jsonDictionary["programStatus"]! as! String
                program.programKey = jsonDictionary["key"]! as! String
                let dateFormatter: NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"
                program.programStartDate = dateFormatter.dateFromString(jsonDictionary["startDate"]! as! String)!
                program.programEndDate = dateFormatter.dateFromString(jsonDictionary["endDate"]! as! String)!
                println(program.programStartDate)
                println(program.programEndDate)
                appDelegate.saveContext()
                println(program)
            }
        }
    }
    
    func importProgramData(responseDict:NSDictionary)->Void{
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("ProgramModel", inManagedObjectContext: managedObjectContext!)
        for var index = 0; index < responseDict["programData"]!.count; index++ {
            let program = ProgramModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
            program.programNr = responseDict["programData"]![index].objectForKey("programNr")! as! String
            program.programName = responseDict["programData"]![index].objectForKey("programName")! as! String
            program.programCompany = responseDict["programData"]![index].objectForKey("programCompany")! as! String
            program.programGoal = Int16(responseDict["programData"]![index].objectForKey("programGoal")! as! Int)
            program.myCount = Int16(responseDict["programData"]![index].objectForKey("myCount")! as! Int)
            program.programsFinished = Int16(responseDict["programData"]![index].objectForKey("ProgramsFinished")! as! Int)
            program.programStatus = responseDict["programData"]![index].objectForKey("programStatus")! as! String
            program.programKey = responseDict["programData"]![index].objectForKey("programKey")! as! String
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"
            program.programStartDate = dateFormatter.dateFromString(responseDict["programData"]![index].objectForKey("programStartDate")! as! String)!
            program.programEndDate = dateFormatter.dateFromString(responseDict["programData"]![index].objectForKey("programEndDate")! as! String)!
            println(program)
            appDelegate.saveContext()
        }
    }
    
    func importNewsData(responseDict: NSDictionary)->Void{
        if responseDict["success"]! as! Bool == true {
            let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("MessageModel", inManagedObjectContext: managedObjectContext!)
            for var index = 0; index < responseDict["newsFeed"]!.count; index++ {
                let message = MessageModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                message.newsTitle = responseDict["newsFeed"]![index].objectForKey("newsTitle")! as! String
                message.newsMessage = responseDict["newsFeed"]![index].objectForKey("newsMessage")! as! String
                message.programName = responseDict["newsFeed"]![index].objectForKey("programName")! as! String
                message.programCompany = responseDict["newsFeed"]![index].objectForKey("company")! as! String
                let dateFormatter: NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"
                message.newsDate = dateFormatter.dateFromString(responseDict["newsFeed"]![index].objectForKey("newsDate")! as! String)!
                message.newsStatus = false
                println("neue Nachricht wird gespeichert:")
                println(message)
                appDelegate.saveContext()
            }
        }
    }
    
    func requestNewsData()->Void{
        var reconTask: ReconciliationModel = self.setReconciliationList(6,setRecLiUser: NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as! String,setRecLiProgNr: "",setRecLiGoalToHit: 0, setRecLiQPCode: "", setRecLiPW: NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as! String, setRecLiGender: 0)
        
        // If Internet Available
        if Reachability.isConnectedToNetwork() {
            self.APIPostRequest(reconTask,apiType: 6){
                (responseDict: NSDictionary) in
            }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluateWithObject(testStr) {
            return true
        }
        return false
    }

}
