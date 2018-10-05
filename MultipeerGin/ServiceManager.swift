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

    private func sendUuid () {
        NSLog("%@", "PLD sending uuid to peer")
        send(dictionary: ["payloadType" : "uuid", "uuid" : localUuid])
    }

    func send (dictionary: [String : Any]) {
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        do {
            try session.send(data, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
    }

    // Internal method called on the main thread handles a data dictionary sent by the peer.
    private func receive (dictionary: [String : Any]) {
        let payloadType = dictionary["payloadType"] as! String
        if payloadType == "uuid" {
            let uuid = dictionary["uuid"] as! String
            NSLog("%@", "PLD received uuid \(uuid). Mine is \(localUuid)")
            delegate?.connectedToOpponent(asMaster: uuid < localUuid)
        } else {
            delegate?.receivedData(dictionary: dictionary)
        }
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
            sendUuid()
        } else if state == .notConnected {
            OperationQueue.main.addOperation {
                self.delegate?.disconnectedFromOpponent()
            }
       }
    }

    // The communication protocol
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
        OperationQueue.main.addOperation {
            self.receive(dictionary: dictionary)
        }
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

    func connectedToOpponent (asMaster: Bool)
    func disconnectedFromOpponent ()
    func receivedData (dictionary: [String : Any])
}
