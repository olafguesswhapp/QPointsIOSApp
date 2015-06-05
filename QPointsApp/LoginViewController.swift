//
//  LoginViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 08.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    var controller:UIAlertController?
    var alertController:UIAlertController?

    @IBOutlet weak var LoginResponseLabel: UILabel!
    @IBOutlet weak var CreateAccountButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var UserPasswordTextField: UITextField!
    @IBOutlet weak var UserEmailTextField: UITextField!
    
    var savedPassword: String = ""
    var savedUserEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller = UIAlertController(title: "Warnung", message: "Auf diesem Gerät waren Sie bisher mit einer anderen User-Email angemeldet.\n\nWollen Sie sich als neuer User anmelden und die auf diesem Gerät gespeicherten Punkte löschen?\nDann drücken Sie bitte unten auf 'New User' und loggen Sie sich erneut ein.", preferredStyle: .ActionSheet)
        let actionNewUser = UIAlertAction(title: "New User",
            style: UIAlertActionStyle.Destructive,
            handler: {(paramAction:UIAlertAction!) in
                println("The New User button was tapped")
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: HASBEENVERIFIED_KEY)
                NSUserDefaults.standardUserDefaults().synchronize()
        })
        let actionCancel = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: {(paramAction:UIAlertAction!) in
        })
        controller!.addAction(actionNewUser)
        controller!.addAction(actionCancel)
        
        alertController = UIAlertController(title: "Warnung", message: "Das Passwort stimmt ist nicht richtig. Bitte versuchen Sie es erneut", preferredStyle: .Alert)
        let actionAlert = UIAlertAction(title: "Done",
            style: UIAlertActionStyle.Default,
            handler: {(paramAction:UIAlertAction!) in
                println("The Done button was tapped")
        })
        alertController!.addAction(actionAlert)

        // Do any additional setup after loading the view.
        self.LoginButton.layer.cornerRadius = 5
        self.CreateAccountButton.layer.cornerRadius = 5
        
        if (NSUserDefaults.standardUserDefaults().boolForKey(HASBEENVERIFIED_KEY) == true) {
            savedUserEmail = NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as! String
            savedPassword = NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as! String
            println("Has been logged in as \(savedUserEmail)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        LoginResponseLabel.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSuccessfulSegue" {
        }
    }
    
    @IBAction func LoginBtnTapped(sender: UIButton) {
        self.view.endEditing(true)
        if (self.isValidEmail(UserEmailTextField.text) as Bool == true){
            if (NSUserDefaults.standardUserDefaults().boolForKey(HASBEENVERIFIED_KEY) == true) {
                if UserEmailTextField.text == self.savedUserEmail {
                    if UserPasswordTextField.text == self.savedPassword {
                        self.performSegueWithIdentifier("loginSuccessfulSegue", sender: self)
                    } else {
                        self.presentViewController(alertController!, animated: true, completion: nil)
                    }
                } else {
                    self.presentViewController(controller!, animated: true, completion: nil)
                }
            } else {
                var reconTask: ReconciliationModel = self.setReconciliationList(3,setRecLiUser: UserEmailTextField.text,setRecLiProgNr: "",setRecLiGoalToHit: 0, setRecLiQPCode: "", setRecLiPW: UserPasswordTextField.text, setRecLiGender: 0)
                // if Internet available ...
                self.APIPostRequest(reconTask,apiType: 3){
                    (responseDict: NSDictionary) in
                    var apiMessage:String = responseDict["message"] as! String
                    var apiSuccess:Bool = responseDict["success"] as! Bool
                    if (apiSuccess == true) {
                        var apiGender:Int = responseDict["gender"] as! Int
                        var interimPW:String = reconTask.reconPassword
                        var interimUser:String = reconTask.reconUser
                        dispatch_async(dispatch_get_main_queue(),{
                            println(interimUser)
                            println(interimPW)
                            NSUserDefaults.standardUserDefaults().setObject(interimUser, forKey: USERMAIL_KEY)
                            NSUserDefaults.standardUserDefaults().setInteger(apiGender, forKey: USERGENDER_KEY)
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: HASBEENVERIFIED_KEY)
                            NSUserDefaults.standardUserDefaults().setObject(interimPW, forKey: PASSWORD_KEY)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.deleteProgramData(responseDict)
                            self.performSegueWithIdentifier("loginSuccessfulSegue", sender: self)
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.LoginResponseLabel.text = apiMessage + "\n\n   Drücken Sie auf 'Konto anlegen' um sich neu anzumelden"
                            self.LoginResponseLabel.hidden = false
                        });
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
