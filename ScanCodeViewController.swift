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
        var reconTask: ReconciliationModel = self.setReconciliationList(1,setRecLiUser: "j2@guesswhapp.de",setRecLiProgNr: "",setRecLiGoalToHit: 0, setRecLiQPCode: CodeInputField.text)
        
        
        CodeInputField.endEditing(true)
        CodeInputField.text = ""
        
        // If Internet Available
        self.APIPostRequest(reconTask,apiType: 1){
            (apiMessage: String) in
            dispatch_async(dispatch_get_main_queue(),{
                self.CodeResponseField.hidden = false
                self.CodeResponseField.text = apiMessage
            });
        }
    }
    
}