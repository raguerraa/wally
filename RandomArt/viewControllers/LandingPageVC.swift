//
//  LandingPageVC.swift
//  RandomArt
//
//  Created by Owner on 8/14/20.
//  Copyright © 2020 ronald. All rights reserved.
//

import UIKit
import CoreGraphics
import SideMenuSwift

class LandingPageVC: UIViewController {

    @IBOutlet weak var canvas: canvasView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // This method opens the side menu.
    @IBAction func close(_ sender: Any) {
        self.sideMenuController?.revealMenu();
    }
    // This method generate Art.
    @IBAction func generateArt(_ sender: Any) {
        canvas.generateArt()
    }
    
}
