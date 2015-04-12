//
//  AddProgramViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 12.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit
import CoreData

class AddProgramViewController: UIViewController {
    
    @IBOutlet weak var programNameInputField: UITextField!
    @IBOutlet weak var programGoalPointsInputField: UITextField!
    @IBOutlet weak var programNrInputField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddButtonPushed(sender: UIButton) {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("ProgramModel", inManagedObjectContext: managedObjectContext!)
        let program = ProgramModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        program.programName = programNameInputField.text
        program.nr = programNrInputField.text
        program.programGoal = programGoalPointsInputField.text.toInt()!
        program.myCount = 0
        program.programStatus = "aktiviert"
        
        appDelegate.saveContext()
        
        var request = NSFetchRequest(entityName: "ProgramModel")
        var error:NSError? = nil
        
        var results:NSArray = managedObjectContext!.executeFetchRequest(request, error: &error)!
        
        for res in results {
            println(res)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func CancelButtonPushed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
