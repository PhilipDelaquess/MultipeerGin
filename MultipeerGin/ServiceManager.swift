//
//  ServiceManager.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 9/17/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServiceManager : NSObject {
    
    private let ServiceType = "pld-gin-game"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    private let localUuid = UUID().uuidString.lowercased()
    private var remoteUuid: String?
    private var remoteConnected = false
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    var delegate : ServiceManagerDelegate?
    
    override init () {
        let info = ["uuid" : localUuid]
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: info, serviceType: ServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        NSLog("%@", "PLD about to start advertising")
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        NSLog("%@", "PLD about to start browsing")
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(colorName : String) {
        NSLog("%@", "sendColor: \(colorName) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
    func discoveredPeer(withUuid uuid : String?) {
        remoteUuid = uuid
        if remoteConnected {
            notifyDelegate()
        }
    }
    
    func connectedPeer () {
        remoteConnected = true
        if remoteUuid != nil {
            notifyDelegate()
        }
    }
    
    func notifyDelegate () {
        let role = remoteUuid! > localUuid ? "slave" : "master"
        self.delegate?.connectedToOpponent(withRole: role)
    }
    
}

extension ServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    // This method is called when a remote peer invites this peer to join a session.
    // Only one peer is ever expected, so accept its invitation. Don't ask the user.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "PLD about to accept invitation from \(peerID.displayName)")
        invitationHandler(true, self.session)
    }
}

extension ServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    // This method is called when the browser finds a remote peer advertising itself.
    // Only one peer is ever expected, so invite it to join a session. Don't ask the user.
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "PLD found and about to invite peer: \(peerID.displayName)")
        discoveredPeer(withUuid: info?["uuid"])
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    // This method is called when the peer goes away.
    // This situation needs to be handled eventually.
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "PLD lost peer: \(peerID.displayName)")
    }
    
}

extension ServiceManager : MCSessionDelegate {
    
    // This method is called when the remote peer connects or disconnects.
    // For now, connection means tell our delegate to segue to the "play" screen,
    // and disconnect means "oops."
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            NSLog("%@", "PLD \(peerID.displayName) connected")
            connectedPeer()
        } else if state == .notConnected {
            self.delegate?.disconnectedFromOpponent()
        }
    }
    
    // The communication protocol
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}

protocol ServiceManagerDelegate {
    
    func connectedToOpponent(withRole: String)
    func disconnectedFromOpponent()
}

