//
//  ViewController.swift
//  AVMCManager
//
//  Created by Arpit Vishwakarma on 04/03/16.
//  Copyright © 2016 Arpit Vishwakarma. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate{

    @IBOutlet var lblStatus:UILabel!
    @IBOutlet var btnSearch:UIButton!
    @IBOutlet var btnSendData:UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerDidChangeStateWithNotification:", name: "MCDidChangeStateNotification", object: nil)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "MCDidStartReceivingResourceNotification:", name: "MCDidStartReceivingResourceNotification", object: nil)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateReceivingProgressWithNotification:", name: "MCReceivingProgressNotification", object: nil)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishReceivingResourceWithNotification:", name: "didFinishReceivingResourceNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "MCDidReceiveDataNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        btnSendData.backgroundColor = UIColor.lightGrayColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*!
    Send your data from here to another connected device
    */
    func sendDataToAnotherDevice (){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        if appDelegate.avManager.session.connectedPeers.count != 0 {
            
            let myDictionary: [NSObject : AnyObject] = ["bgColor": btnSendData.backgroundColor!, "object2Key": "object2Value", "object3Key": "object3Value"]
            let dataToSend:NSData = NSKeyedArchiver.archivedDataWithRootObject(myDictionary)
            let allPeers = appDelegate.avManager?.session.connectedPeers
            do{
                try appDelegate.avManager.session.sendData(dataToSend, toPeers: allPeers!, withMode: MCSessionSendDataMode.Unreliable)
            }catch {
                print("failed")
            }
        }
        
    }
    
    /*!
    Search device and connect with devices
    */
    @IBAction func searchDevice() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        appDelegate.avManager.setupMCBrowser()
        appDelegate.avManager.browser.delegate = self
        self.presentViewController(appDelegate.avManager.browser, animated: true, completion: nil)
        
    }
    

    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    @IBAction func sendDataTODevice() {
        
        btnSendData.backgroundColor = self.getRandomColor()
        self.sendDataToAnotherDevice()
    }


    /*!
    Notifies the delegate, when the user taps the done button.
    
    - parameter browserViewController: MCBrowserViewController object
    */
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        appDelegate.avManager.browser.dismissViewControllerAnimated(true, completion: nil)

    }
    
    /*!
    Notifies delegate that the user taps the cancel button.
    
    - parameter browserViewController: MCBrowserViewController object
    */
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 

        appDelegate.avManager.browser.dismissViewControllerAnimated(true, completion: nil)

    }
    
    
    /*!
    Get the peer change state observer for the session

    - parameter notification: notification object
    */
    
    func peerDidChangeStateWithNotification(notification:NSNotification){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        let state = userInfo["state"] as! NSInteger
        
        print(userInfo)
        print(state)
        
        if state == 2 {
            lblStatus.text = "Connected"
        }else if state == 1 {
            lblStatus.text = "Connecting"

        }else if state == 0 {
            lblStatus.text = "NotConnected"
            
        }
        appDelegate.avManager.browser.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func didStartReceivingResourceWithNotification(notification:NSNotification){
        
    }
    
    func updateReceivingProgressWithNotification(notification:NSNotification){
        
    }
    
    func didFinishReceivingResourceWithNotification(notification:NSNotification){
        
    }
    
    /*!
    Handle the received data from the connected peer.
    
    - parameter notification: notification object
    */
    
    func didReceiveDataWithNotification(notification:NSNotification){
     
        let peerID: MCPeerID = (notification.userInfo!["peerID"] as! MCPeerID)
        let peerDisplayName: String = peerID.displayName
        let msg: String = "\(peerDisplayName) want to share something with you."
       
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        let receivedData = userInfo["data"] as? NSData
        let receivedDict = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData!) as! NSDictionary
        
        
        
        let alertController = UIAlertController(title: "Message", message: msg, preferredStyle: .Alert)
        let nextAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Default) { action -> Void in
            //Do some other stuff
            self.view.backgroundColor = receivedDict["bgColor"] as? UIColor

        }
        
        alertController.addAction(nextAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
   
}

