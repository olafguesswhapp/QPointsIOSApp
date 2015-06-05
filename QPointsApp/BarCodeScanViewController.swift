//
//  BarCodeScanViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 24.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit
import AVFoundation

class BarCodeScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let session         : AVCaptureSession = AVCaptureSession()
    var previewLayer    : AVCaptureVideoPreviewLayer!
    var highlightView   : UIView = UIView()
    
    var messageController:UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Allow the view to resize freely
        self.highlightView.autoresizingMask =   UIViewAutoresizing.FlexibleTopMargin |
            UIViewAutoresizing.FlexibleBottomMargin |
            UIViewAutoresizing.FlexibleLeftMargin |
            UIViewAutoresizing.FlexibleRightMargin
        // Select the color you want for the completed scan reticle
        self.highlightView.layer.borderColor = UIColor.greenColor().CGColor
        self.highlightView.layer.borderWidth = 3
        // Add it to our controller’s view as a subview.
        self.view.addSubview(self.highlightView)
        
        // For the sake of discussion this is the camera
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        // Create a nilable NSError to hand off to the next method.
        // Make sure to use the “var” keyword and not “let”
        var error : NSError? = nil
        let input : AVCaptureDeviceInput? = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput
        // If our input is not nil then add it to the session, otherwise we’re kind of done!
        if input != nil {
            session.addInput(input)
        }
        else {
            // This is fine for a demo, do something real with this in your app. :)
            println(error)
        }
    
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as! AVCaptureVideoPreviewLayer
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        session.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.view.sendSubviewToBack(self.highlightView)
        if (session.running){
            self.session.stopRunning()
       }
    }
    
    // This is called when we find a known barcode type with the camera.
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRectZero
        var barCodeObject : AVMetadataObject!
        var detectionString : String!
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
            AVMetadataObjectTypeCode39Code,
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode93Code,
            AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code,
            AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeAztecCode
        ]
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for metadata in metadataObjects {
            
            for barcodeType in barCodeTypes {
                if metadata.type == barcodeType {
                    
                    barCodeObject = self.previewLayer.transformedMetadataObjectForMetadataObject(metadata as! AVMetadataMachineReadableCodeObject)
                    highlightViewRect = barCodeObject.bounds
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.session.stopRunning()
                    break
                }
            }
        }
        
        self.highlightView.frame = highlightViewRect
        self.view.bringSubviewToFront(self.highlightView)
        println(detectionString)
        
        if detectionString != nil {
            var reconTask: ReconciliationModel = self.setReconciliationList(1,setRecLiUser: NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as! String,setRecLiProgNr: "",setRecLiGoalToHit: 0, setRecLiQPCode: detectionString, setRecLiPW: "", setRecLiGender: 0)
            
            // If Internet Available
            self.APIPostRequest(reconTask,apiType: 1){
                (responseDict: NSDictionary) in
                dispatch_async(dispatch_get_main_queue(),{
                    var apiMessage:String = responseDict["message"]as! String
                    self.messageController = UIAlertController(title: "QPoint Scan", message: apiMessage, preferredStyle: .Alert)
                    let actionAlert = UIAlertAction(title: "Ok",
                        style: UIAlertActionStyle.Default,
                        handler: {(paramAction:UIAlertAction!) in
                            self.view.sendSubviewToBack(self.highlightView)
                            self.session.startRunning()
                            println("The Done button was tapped")
                    })
                    self.messageController!.addAction(actionAlert)
                    self.presentViewController(self.messageController!, animated: true, completion: nil)
                    println(apiMessage)
                });
            }
        } else {
            println("")
            self.view.sendSubviewToBack(self.highlightView)
            self.session.startRunning()
        }
    }
}
