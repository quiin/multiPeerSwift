//
//  ViewController.swift
//  multiPeer
//
//  Created by Carlos Alejandro Reyna González on 26/10/15.
//  Copyright © 2015 itesm. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {

    //Outlets
    @IBOutlet weak var tv_chat: UITextView!
    @IBOutlet weak var tf_msg: UITextField!
    
    //vars
    var devices:NSMutableArray = NSMutableArray()
    var session:MCSession!
    var publisher:MCAdvertiserAssistant! //difunde datos del dispositivo
    var browser:MCBrowserViewController! //shows nearby devices
    var peerID: MCPeerID! //device info
    
    let serviceType = "myChat"
    
    
    //MARK - button clicks
    @IBAction func connect(sender: UIButton) {
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.browser.delegate = self
        self.presentViewController(self.browser, animated: true, completion: nil)
        
    }
    
    @IBAction func disconnect(sender: UIButton) {
        self.publisher.stop()
        self.publisher.delegate = nil
        self.session.disconnect()
        self.session.delegate = nil
        self.devices.removeAllObjects()
        self.configureSession()
    }
    
    
    //MARK - broeser methods
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        self.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        self.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK - session methods
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        //conecta/descontecta/cancela
        let peerName = peerID.displayName
        
        switch state{
        case MCSessionState.Connecting:
            print("Conectado con \(peerName)")
            
        case MCSessionState.Connected:
            print("Conectando con \(peerName)")
            self.devices.addObject(peerName)
            print("Conectados: \(self.devices)")
            
        case MCSessionState.NotConnected:
            print("\(peerName) se desconecto")
        }
        
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let receivedMsg = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("Data: \(receivedMsg!)")
    }
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        //
    }
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        //
    }
    
    //MARK -
    @IBAction func send(sender: AnyObject) {
        let msg = self.tf_msg.text?.dataUsingEncoding(NSUTF8StringEncoding)
        let connectedPeers = self.session.connectedPeers
        do{
            try self.session.sendData(msg!, toPeers: connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }catch{
            print("I am kill :(")
        }
        
        self.tv_chat.text = self.tv_chat.text.stringByAppendingString("\nYo:\n\(self.tf_msg.text!)\n")
    }
    
    private func configureSession(){
        self.peerID = MCPeerID(displayName: "(º____º)")
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        self.publisher = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        self.publisher.start() //comienza a difundir datos del dispositivo
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

