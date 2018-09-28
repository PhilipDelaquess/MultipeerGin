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
    func connectedToOpponent(withRole role : String) {
        OperationQueue.main.addOperation {
            self.statusLabel!.text = "Connected with role \(role). Yay!"
        }
    }
    
    func disconnectedFromOpponent() {
        OperationQueue.main.addOperation {
            self.statusLabel!.text = "Shit! Came unconnected"
        }
    }
    
    
}
