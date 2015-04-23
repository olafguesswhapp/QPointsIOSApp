    //
//  ScanCodeViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 13.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit
import CoreData

class ScanCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var CodeInputField: UITextField!
    @IBOutlet weak var CodeResponseField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CodeInputField.delegate = self

        // Do any additional setup after loading the view.
        CodeResponseField.text = ""
        // CodeResponseField.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {    //delegate method
        CodeResponseField.hidden = true
    }
    
    @IBAction func ScanButtonTapped(sender: UIButton) {
        requestProgramData(CodeInputField.text)
        CodeInputField.endEditing(true)
        CodeInputField.text = ""
    }
    
    func requestProgramData(scannedCode: String) {
        // Prepare API Post request
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicodecheck")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "user" : "j2@guesswhapp.de",
            "qpInput" : scannedCode // new scanned code
        ]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // API Post request
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary!)
            dispatch_async(dispatch_get_main_queue(),{
                self.CodeResponseField.hidden = false
                self.CodeResponseField.text = jsonDictionary!["message"]! as? String
            });
            // handle API response only if code is valid - success = true
            if jsonDictionary!["success"]! as Bool == true {
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
                        if fetchResults[index].programNr == jsonDictionary!["nr"]! as String {
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
                    program.programNr = jsonDictionary!["nr"]! as String
                    program.programName = jsonDictionary!["name"]! as String
                    program.programCompany = jsonDictionary!["company"]! as String
                    var helpInt: Int = jsonDictionary!["goalCount"]! as Int
                    program.programGoal = Int16(helpInt)
                    program.myCount = 1
                    program.programStatus = jsonDictionary!["programStatus"]! as String
                    program.programKey = jsonDictionary!["key"]! as String
                    let dateFormatter: NSDateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"
                    program.programStartDate = dateFormatter.dateFromString(jsonDictionary!["startDate"]! as String)!
                    program.programEndDate = dateFormatter.dateFromString(jsonDictionary!["endDate"]! as String)!
                    println(program.programStartDate)
                    println(program.programEndDate)
                    appDelegate.saveContext()
                    println(program)
                }
            }
        })
        task.resume()
    }
}