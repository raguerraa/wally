//
//  DownloadVC.swift
//  RandomArt
//
//  Created by ronald Guerra on 4/12/22.
//  Copyright © 2022 ronald. All rights reserved.
//
//  This presents a wallpaper along with its metadata and it can be downloaded by the user.


import UIKit

class DownloadVC: UIViewController {

    @IBOutlet weak var wallpaperView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var complexityLabel: UILabel!
    
    var imageName = String()
    var wallpaperName = String()
    var complexity = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wallpaperView.image = UIImage(named: imageName)
        nameLabel.text = wallpaperName
        complexityLabel.text = String(complexity) + "%"
    }
    
    // Saves the wallpaper to the user Photo Library.
    @IBAction func downloadWallpaper(_ sender: Any) {
        if let image = UIImage(named: imageName){
            saveImage(image: image)
        }
    }
}
