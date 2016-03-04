//
//  AVMCManager.swift
//  AVMCManager
//
//  Created by Arpit Vishwakarma on 04/03/16.
//  Copyright © 2016 Arpit Vishwakarma. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class AVMCManager: NSObject, MCSessionDelegate {

    /// Peers are uniquely identified by an MCPeerID object, which are initialized with a display name. This could be a user-specified nickname, or simply the current device name
    var peerID: MCPeerID!
    
    /// sessions are created by advertisers, and passed to peers when accepting an invitation to connect
    var session: MCSession!
    
    /// MCBrowserViewController offers a built-in, standard way to present and connect to advertising peers
    var browser: MCBrowserViewController!
    
    /// Services are advertised by the MCAdvertiserAssistant, which is initialized with a local peer, service type, and any optional information to be communicated to peers that discover the service
    var advertiser: MCAdvertiserAssistant!
    
    override init() {
        super.init()
        peerID = nil
        session = nil
        browser = nil
        advertiser = nil
    }
   
    /*!
    * Setup peer and session for the device with name
    
    - parameter displayName: device display name
    */
    
    func setupPeerAndSessionWithDisplayName(displayName: String) {
        self.peerID = MCPeerID(displayName: displayName)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
    }
    
    /*!
    * Search the devices
    */
    func setupMCBrowser() {
        self.browser = MCBrowserViewController(serviceType: "AVSharingApp", session: session)
    }
    
    /*!
    * Advertise the devices
    */
    
    func advertiseSelf(shouldAdvertise: Bool) {
        if shouldAdvertise {
            self.advertiser = MCAdvertiserAssistant(serviceType: "AVSharingApp", discoveryInfo: nil, session: session)
            advertiser.start()
        }
        else {
            advertiser.stop()
            self.advertiser = nil
        }
    }
    
    /*!
    Get the peer change state observer for the session
    
    - parameter session: session object
    - parameter peerID:  peerID for device
    - parameter state:   changing state
    */
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        let dict: [NSObject : AnyObject] = ["peerID": peerID, "state":NSNumber(integer: state.rawValue)]
        //NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: dict)
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dict)

    }
    
    /*!
    Receice data from the connected device
    
    - parameter session: current session
    - parameter data:    receiving data
    - parameter peerID:  receiving peer id
    */
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let dict: [NSObject : AnyObject] = ["data": data, "peerID": peerID]
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidReceiveDataNotification", object: nil, userInfo: dict)
    }

    
    /*!
    Its name clearly states its purpose, and we will use it to keep track of the progress while a new file is being received.
    
    - parameter session:      current session
    - parameter resourceName: resourceName object
    - parameter peerID:       receiving peer id
    - parameter progress:     progress for receiving data
    */
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        let dict: [NSObject : AnyObject] = ["resourceName": resourceName, "peerID": peerID, "progress": progress]
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidStartReceivingResourceNotification", object: nil, userInfo: dict)
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: nil)
        })
    }
    
    
    /*!
    This is invoked when a resource has been received, and as usual, we’ll post a new notification
    
    - parameter session:      current session
    - parameter resourceName: resourceName object
    - parameter peerID:       receiving peer id
    - parameter localURL:     localURL object
    - parameter error:        error object
    */
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        let dict: [NSObject : AnyObject] = ["resourceName": resourceName, "peerID": peerID, "localURL": localURL]
        NSNotificationCenter.defaultCenter().postNotificationName("didFinishReceivingResourceNotification", object: nil, userInfo: dict)
    }
    
    /*!
    Streams are received by the MCSessionDelegate both the input and output streams must be scheduled and opened before they can be used. Once that’s done, streams can be read from and written to just like any other bound pair
    
    - parameter session:    current session
    - parameter stream:     stream object
    - parameter streamName: streamName object
    - parameter peerID:     peerID object
    */
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
         NSNotificationCenter.defaultCenter().postNotificationName("MCReceivingProgressNotification", object: nil, userInfo: ["progress": (object as! NSProgress)])
    }
}
