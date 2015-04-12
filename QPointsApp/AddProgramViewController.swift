//
//  AddProgramViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 12.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class AddProgramViewController: UIViewController {
    
    var mainVC: ViewController!
    
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
        var program = ProgramModel(nr: programNrInputField.text, programName: programNameInputField.text, programGoal: programGoalPointsInputField.text.toInt()!, myCount: 0)
        mainVC?.programs.append(program)
        println(mainVC.programs)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func CancelButtonPushed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
