//
//  profileViewController.swift
//  Tender
//
//  Created by Vishal Anantharaman on 3/28/20.
//  Copyright © 2020 Vishal Anantharaman. All rights reserved.
//

import UIKit
import Firebase

class profileViewController: UIViewController {

    @IBOutlet weak var username: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.username.text = UserDefaults.standard.string(forKey: "_USERNAME")
    }

    @IBAction func logoutClicked(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "_USERNAME")
        UserDefaults.standard.set(nil, forKey: "_PASSWORD")
        do {
            try Auth.auth().signOut()
        } catch {
            print("error")
        }
        self.parent?.dismiss(animated: true, completion: nil)
    }
}
