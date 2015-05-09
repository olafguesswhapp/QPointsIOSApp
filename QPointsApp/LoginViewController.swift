//
//  LoginViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 08.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var LoginResponseLabel: UILabel!
    @IBOutlet weak var CreateAccountButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var UserPasswordTextField: UITextField!
    @IBOutlet weak var UserEmailTextField: UITextField!
    
    var savedPassword: String = ""
    var savedUserEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.LoginButton.layer.cornerRadius = 5
        self.CreateAccountButton.layer.cornerRadius = 5
        
        if (NSUserDefaults.standardUserDefaults().boolForKey(HASBEENVERIFIED_KEY) == true) {
            savedUserEmail = NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as String
            savedPassword = NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as String
            println("Has been logged in as \(savedUserEmail)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        LoginResponseLabel.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSuccessfulSegue" {
            
        }
    }
    
    @IBAction func LoginBtnTapped(sender: UIButton) {
        if (self.isValidEmail(UserEmailTextField.text) as Bool == true){
            if (NSUserDefaults.standardUserDefaults().boolForKey(HASBEENVERIFIED_KEY) == true) {
                if UserEmailTextField.text == self.savedUserEmail && UserPasswordTextField.text == self.savedPassword {
                    self.performSegueWithIdentifier("loginSuccessfulSegue", sender: self)
                } else {
                    self.LoginResponseLabel.text = "Bitte überprüfen Sie Ihre Eingabe (Email oder Passwort ist falsch)"
                    self.LoginResponseLabel.hidden = false
                }
            } else {
                var reconTask: ReconciliationModel = self.setReconciliationList(3,setRecLiUser: UserEmailTextField.text,setRecLiProgNr: "",setRecLiGoalToHit: 0, setRecLiQPCode: "", setRecLiPW: UserPasswordTextField.text)
                // if Internet available ...
                self.APIPostRequest(reconTask,apiType: 3){
                    (apiMessage: String) in
                    if (apiMessage == "User-Email und Passwort sind verifiziert. Willkommen") {
                        var interimPW:String = reconTask.reconPassword
                        dispatch_async(dispatch_get_main_queue(),{
                            println(reconTask.reconUser)
                            println(interimPW)
                            NSUserDefaults.standardUserDefaults().setObject(reconTask.reconUser, forKey: USERMAIL_KEY)
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: HASBEENVERIFIED_KEY)
                            NSUserDefaults.standardUserDefaults().setObject(interimPW, forKey: PASSWORD_KEY)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.performSegueWithIdentifier("loginSuccessfulSegue", sender: self)
                        });
                    } else {
                        self.LoginResponseLabel.text = apiMessage
                        self.LoginResponseLabel.hidden = false
                    }
                }
            }
        } else {
            self.LoginResponseLabel.text = "Bitte geben Sie eine gültige Email-Adresse ein"
            self.LoginResponseLabel.hidden = false
        }
    }

    @IBAction func CreateAccountBtnTapped(sender: UIButton) {
        performSegueWithIdentifier("createAccountSegue", sender: self)
    }
}
