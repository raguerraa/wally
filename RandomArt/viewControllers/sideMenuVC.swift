//
//  sideMenuVC.swift
//  RandomArt
//
//  Created by Owner on 8/14/20.
//  Copyright © 2020 ronald. All rights reserved.
//

import UIKit
import SideMenuSwift

class sideMenuVC: UIViewController {
    
    let canvasStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let yourWorkStoryboard = UIStoryboard(name: "yourWork", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        sideMenuController?.cache(viewControllerGenerator: {
            self.canvasStoryboard.instantiateViewController(withIdentifier: "canvas")
        }, with: "canvas")

        sideMenuController?.cache(viewControllerGenerator: {
            self.yourWorkStoryboard.instantiateViewController(withIdentifier: "yourWork")
        }, with: "yourWork")
    }
    
    
    @IBAction func showCanvas(_ sender: Any) {
        
        sideMenuController?.setContentViewController(with: "canvas")
        
        sideMenuController?.hideMenu()
    }
    
    @IBAction func showSettings(_ sender: Any) {
    }
    
    @IBAction func showYourWork(_ sender: Any) {
        
        sideMenuController?.setContentViewController(with: "yourWork")
               
        sideMenuController?.hideMenu()
    }
}
