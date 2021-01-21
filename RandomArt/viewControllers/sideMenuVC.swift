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

    @IBOutlet weak var profileView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureProfileView()
        sideMenuController?.cache(viewControllerGenerator: {
            self.canvasStoryboard.instantiateViewController(withIdentifier: "canvas")
        }, with: "canvas")

        sideMenuController?.cache(viewControllerGenerator: {
            self.yourWorkStoryboard.instantiateViewController(withIdentifier: "yourWork")
        }, with: "yourWork")
    }
    
    func configureProfileView(){
        profileView.layer.borderWidth = 2
        profileView.layer.masksToBounds = false
        profileView.layer.borderColor = UIColor.white.cgColor
        profileView.layer.cornerRadius = profileView.frame.height/2
        profileView.clipsToBounds = true
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
