//
//  SideMenuVC.swift
//  RandomArt
//
//  Modified by Ronald on 4/15/22.
//  Copyright © 2020 Ronald. All rights reserved.
//

import UIKit
import SideMenuSwift

class SideMenuVC: UIViewController {
    
    let canvasStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let freeCollectionStoryboard = UIStoryboard(name: "FreeCollection", bundle: nil)
    let howToChangeWallpaper = UIStoryboard(name: "HowToChangeWallpaper", bundle: nil)

    @IBOutlet weak var profileView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureProfileView()
        sideMenuController?.cache(viewControllerGenerator: {
            self.canvasStoryboard.instantiateViewController(withIdentifier: "canvas")
        }, with: "canvas")

        sideMenuController?.cache(viewControllerGenerator: {
            self.freeCollectionStoryboard.instantiateViewController(withIdentifier: "freeCollection")
        }, with: "freeCollection")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.howToChangeWallpaper.instantiateViewController(withIdentifier: "howToChangeWallpaper")
        }, with: "howToChangeWallpaper")
        
        sideMenuController?.setContentViewController(with: "canvas")
        sideMenuController?.hideMenu()
    }
    
    func configureProfileView(){
        profileView.layer.borderWidth = 2
        profileView.layer.masksToBounds = false
        profileView.layer.borderColor = UIColor.white.cgColor
        profileView.layer.cornerRadius = profileView.frame.height/2
        profileView.clipsToBounds = true
    }
    // This shows the canvas
    @IBAction func showCanvas(_ sender: Any) {
        
        sideMenuController?.setContentViewController(with: "canvas")
        sideMenuController?.hideMenu()
    }
    // This shows the PDF
    @IBAction func showHowToChangeWallpaper(_ sender: Any) {
        
        sideMenuController?.setContentViewController(with: "howToChangeWallpaper")
        sideMenuController?.hideMenu()
    }
    
    @IBAction func showYourWork(_ sender: Any) {
        
        sideMenuController?.setContentViewController(with: "freeCollection")
        sideMenuController?.hideMenu()
    }
}
