    //
//  ScanCodeViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 13.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit
import CoreData

class ScanCodeViewController: UIViewController {

    @IBOutlet weak var CodeInputField: UITextField!
    @IBOutlet weak var CodeResponseField: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ScanButtonTapped(sender: UIButton) {
        requestProgramData(CodeInputField.text)
        CodeInputField.endEditing(true)
        CodeInputField.text = ""
    }
    
    func requestProgramData(scannedCode: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicodecheck")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "user" : "j2@guesswhapp.de",
            "qpInput" : scannedCode
        ]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var helpDict: NSDictionary = [String : Float]()
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println("JSON DICT:")
            println(jsonDictionary!)
            dispatch_async(dispatch_get_main_queue(),{
                self.CodeResponseField.hidden = false
                self.CodeResponseField.text = jsonDictionary!["message"]! as? String
            });
            var isNewProgram: Bool = true
            let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("ProgramModel", inManagedObjectContext: managedObjectContext!)
            let fetchRequest = NSFetchRequest(entityName: "ProgramModel")
            // Execute the fetch request, and cast the results to an array of LogItem objects
            if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProgramModel] {
                
                var index: Int
                for index = 0; index<fetchResults.count; ++index{
                    if fetchResults[index].programNr == jsonDictionary!["nr"]! as String {
                        isNewProgram = false
                        fetchResults[index].myCount += 1
                        println(fetchResults[index].myCount)
                        appDelegate.saveContext()
                    }
                }
            }
            println(isNewProgram)
            if isNewProgram == true {

                let program = ProgramModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                program.programNr = jsonDictionary!["nr"]! as String
                program.programName = jsonDictionary!["name"]! as String
                var helpInt: Int = jsonDictionary!["goalCount"]! as Int
                program.programGoal = Int16(helpInt)
                program.myCount = 1
                program.programStatus = jsonDictionary!["programStatus"]! as String
                
                appDelegate.saveContext()
            }
        })
        task.resume()
    }

}
