//
//  ViewController.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 2/3/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    let service = ServiceManager();

    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : ServiceManagerDelegate {
    func connectedToOpponent (asMaster master : Bool) {
        self.statusLabel!.text = "Connected with role \(master ? "master" : "slave"). Yay!"
        if master {
            service.sendInitialGameState()
        }
    }

    func disconnectedFromOpponent () {
        self.statusLabel!.text = "Shit! Came unconnected"
    }

    func receivedInitialGameState () {
        
    }
}
