//
//  ProfileViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 19.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate {
    
    var controller:UIAlertController?

    @IBOutlet weak var UserEmailTextField: UITextField!

    @IBOutlet weak var UserPasswordTextField1: UITextField!
    @IBOutlet weak var UserPasswordTextField2: UITextField!
    @IBOutlet weak var SaveProfileUpdateButton: UIButton!
    @IBOutlet weak var UserGenderPicker: UIPickerView!
    
    var userGender = ["Nicht angeben", "Weiblich", "Männlich"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let brandView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 31))
        brandView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "QPointsBrand")
        brandView.image = image
        self.navigationItem.titleView = brandView
        
        self.view.backgroundColor = QPColors.dunkelBlau
        self.SaveProfileUpdateButton.backgroundColor = QPColors.dunkelRot
        self.SaveProfileUpdateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        controller = UIAlertController(title: "Warnung", message: "Bitte stellen Sie sicher, dass beide Passwort Eingaben identisch sind", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Done",
            style: UIAlertActionStyle.Default,
            handler: {(paramAction:UIAlertAction!) in
                println("The Done button was tapped")
        })
        controller!.addAction(action)

        // Do any additional setup after loading the view.
        UserEmailTextField.text = NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as? String
        UserEmailTextField.userInteractionEnabled = false
        UserPasswordTextField1.text = NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as? String
        UserPasswordTextField2.text = NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as? String
        UserGenderPicker.dataSource = self
        UserGenderPicker.delegate = self
        self.SaveProfileUpdateButton.layer.cornerRadius = 5
        UserGenderPicker.selectRow(NSUserDefaults.standardUserDefaults().objectForKey(USERGENDER_KEY) as! Int, inComponent: 0, animated: true)
        
        self.UserPasswordTextField2.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LogoutSegue" {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func LogoutBtnTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("LogoutSegue", sender: self)
    }
    
    @IBAction func SaveProfileUpdateBtnTapped(sender: UIButton) {
        if (self.UserPasswordTextField1.text == self.UserPasswordTextField2.text){
            var gender: Int16 = Int16(UserGenderPicker.selectedRowInComponent(0))
            NSUserDefaults.standardUserDefaults().setInteger(UserGenderPicker.selectedRowInComponent(0), forKey: USERGENDER_KEY)
            var reconTask: ReconciliationModel = self.setReconciliationList(5, setRecLiUser: UserEmailTextField.text, setRecLiProgNr: "", setRecLiGoalToHit: 0, setRecLiQPCode: UserPasswordTextField2.text, setRecLiPW: NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as! String, setRecLiGender: gender)
            println(reconTask)
            
            // If Internet vorhanden
            if Reachability.isConnectedToNetwork() {
                self.APIPostRequest(reconTask,apiType: 5){
                    (responseDict: NSDictionary) in
                    
                    if (responseDict["success"] as! Bool == false) {
                        println("Update of User Profile not successful according to Server")
                        println(responseDict["message"] as! String)
                    } else {
                        println("Update of Profile successfull")
                        NSUserDefaults.standardUserDefaults().setObject(reconTask.reconQpInput, forKey: PASSWORD_KEY)
                        NSUserDefaults.standardUserDefaults().setInteger(self.UserGenderPicker.selectedRowInComponent(0), forKey: USERGENDER_KEY)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
            }
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.presentViewController(controller!, animated: true, completion: nil)
        }
    }
    
    // UIPicker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userGender.count
    }
    
    // UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView
        {
        var pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.whiteColor()
        pickerLabel.text = userGender[row]
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
