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
                    NSUserDefaults.standardUserDefaults().setObject(UserEmailTextField.text, forKey: USERMAIL_KEY)
                    NSUserDefaults.standardUserDefaults().setObject(Password1TextField.text, forKey: PASSWORD_KEY)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    println("Username: \(NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as String)")
                    println("Passwort: \(NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as String)")
                    performSegueWithIdentifier("createdAccountSuccessfulSegue", sender: self)
                }else {
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
    
    @IBAction func CancelBtnTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
