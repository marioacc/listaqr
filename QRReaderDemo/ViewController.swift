//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Simon Ng on 23/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    
    
    @IBOutlet weak var messageLabel:UILabel!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var lastData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        
        if (error != nil) {
            // If any error occurs, simply log the description of it and don't continue any more.
            println("\(error?.localizedDescription)")
            return
        }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as! AVCaptureInput)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        
        
        
        view.bringSubviewToFront(messageLabel)
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.blueColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 4
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
        // Start video capture.
        captureSession?.startRunning()
        
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "Enfoque el codigo QR"
            return
        }
        
        // Get the metadata object.
        var metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            
            if (metadataObj.stringValue != nil && metadataObj.stringValue != lastData) {
                lastData = metadataObj.stringValue
                let datosDelAlumno: [String] = metadataObj.stringValue.componentsSeparatedByString(",")
                let asistenteObject = PFObject(className: "alumno")
                asistenteObject["Matricula"] = datosDelAlumno[0]
                asistenteObject["Nombre"] = datosDelAlumno[1]
                asistenteObject["Apellido_paterno"] = datosDelAlumno[2]
                asistenteObject["Apellido_materno"] = datosDelAlumno[3]
                asistenteObject["Carrera"] = datosDelAlumno[4]
                //Get todays date and time
                let localdate = NSDate().dateByAddingTimeInterval(-21600)
                asistenteObject["Fecha_hora"] = localdate
                asistenteObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    println("Object has been saved.")
                    if success {
                        let barCodeObject = self.videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                        self.qrCodeFrameView?.frame = barCodeObject.bounds
                        self.messageLabel.text = "Asistencia de "+metadataObj.stringValue.componentsSeparatedByString(",")[1]+" registrada"
                    }
                    
                }
                if metadataObj.stringValue != lastData{
                    let barCodeObject = self.videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                    self.qrCodeFrameView?.frame = barCodeObject.bounds
                }

                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        
        
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

