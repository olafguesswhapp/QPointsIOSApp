//
//  CreateAccountViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 09.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var InputResponseLabel: UILabel!
    @IBOutlet weak var UserEmailTextField: UITextField!
    @IBOutlet weak var Password1TextField: UITextField!
    @IBOutlet weak var Password2TextField: UITextField!
    @IBOutlet weak var CreateAccountButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        CreateAccountButton.layer.cornerRadius = 5
        CancelButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        InputResponseLabel.hidden = true
    }
    
    @IBAction func CreateAccountBtnTapped(sender: UIButton) {
        println("\(UserEmailTextField.text)")
        println(Password1TextField.text)
        println(Password2TextField.text)
        if UserEmailTextField.text != nil && Password1TextField.text != nil {
            if (self.isValidEmail(UserEmailTextField.text) as Bool == true) {
                if Password1TextField.text == Password2TextField.text {
                    var reconTask: ReconciliationModel = self.setReconciliationList(4,setRecLiUser: UserEmailTextField.text,setRecLiProgNr: "",setRecLiGoalToHit: 0, setRecLiQPCode: "", setRecLiPW: Password1TextField.text)
                    // if Internet available ...
                    self.APIPostRequest(reconTask,apiType: 4){
                        (apiMessage: String) in
                        if (apiMessage == "Willkommen bei QPoints - vielen Dank für das Einrichten eines neuen Kontos") {
                            var interimPW:String = reconTask.reconPassword
                            dispatch_async(dispatch_get_main_queue(),{
                                NSUserDefaults.standardUserDefaults().setObject(reconTask.reconUser, forKey: USERMAIL_KEY)
                                NSUserDefaults.standardUserDefaults().setObject(interimPW, forKey: PASSWORD_KEY)
                                NSUserDefaults.standardUserDefaults().synchronize()
                                println("Username: \(NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as String)")
                                println("Passwort: \(NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as String)")
                                self.performSegueWithIdentifier("createdAccountSuccessfulSegue", sender: self)
                            });
                        } else {
                            self.InputResponseLabel.text = apiMessage
                            self.InputResponseLabel.hidden = false
                        }
                    }
                } else {
                    InputResponseLabel.text = "Bitte wiederholen Sie das Passwort im dritten Eingabe-Feld"
                    InputResponseLabel.hidden = false
                }
            } else {
                InputResponseLabel.text = "Bitte geben Sie die Email im richtigen Format ein\nname@Host-Name.Top-Level-Domain\n\nz.B.\n\nmax@mustermann.com"
                InputResponseLabel.hidden = false
            }
        } else {
            InputResponseLabel.text = "Bitte geben Sie Ihre Email und Ihr Passwort ein"
            InputResponseLabel.hidden = false
        }
    }
    
    @IBAction func CancelCreateAccountTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
