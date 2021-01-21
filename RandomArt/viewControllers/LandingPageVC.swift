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
import NVActivityIndicatorView


enum StorageType {
    case userDefaults
    case fileSystem
}

class LandingPageVC: UIViewController {

    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var canvas: canvasView!
    
    
    @IBOutlet weak var pressMeView: NVActivityIndicatorView!
    @IBOutlet weak var progressView: NVActivityIndicatorView!
    let theme = ThemeManager.currentTheme()
    var appBarViewController = UINavigationController()
    let goButton = UIButton()
    
    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .black
        configureCanvas()
        configureGoButton()
        pressMeView.startAnimating()
    }

     // This method opens the side menu.
    @objc func menuItemTapped(sender: Any) {
        self.sideMenuController?.revealMenu();
    }
    
    
    private func configureCanvas(){
        canvas.layer.borderWidth = 3
        canvas.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        canvas.layer.cornerRadius = 5
        canvas.clipsToBounds = true
    }
    
    @IBAction func menuItemTap(_ sender: Any) {
        self.sideMenuController?.revealMenu();
    }
    
    private func configureGoButton(){
        
        goButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        view.addSubview(goButton)
        goButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           /*goButton.bottomAnchor.constraint(equalTo: canvas.bottomAnchor),*/
                           goButton.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -20),
                           goButton.widthAnchor.constraint(equalToConstant: 80),
                           goButton.heightAnchor.constraint(equalToConstant: 80)
                           ]
        NSLayoutConstraint.activate(constraints)
        goButton.layer.cornerRadius = 0.5 * goButton.bounds.size.width
        goButton.clipsToBounds = true
        
        goButton.backgroundColor = UIColor(white: 1, alpha: 0)
        goButton.layer.borderWidth = 2
        goButton.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor /*UIColor.init(red: 35/255, green: 74/255, blue: 247/255,
                                                  alpha:01).cgColor*/
        if #available(iOS 13.0, *) {
            let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
            
            goButton.setImage(UIImage(systemName: "camera.fill", withConfiguration: boldConfig),
                              for: .normal)
            goButton.tintColor = UIColor.black//UIColor.init(red: 54/225, green: 34/225, blue: 4/225, alpha: 1)
            
            goButton.contentVerticalAlignment = .fill
            goButton.contentHorizontalAlignment = .fill
            goButton.imageEdgeInsets = UIEdgeInsets(top: 22, left: 15, bottom: 22, right: 15)
        } else {
            goButton.setTitle("Go", for: .normal)
        }
        
        goButton.setTitleColor(UIColor.blue, for: .normal)
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
    }
    
    // This method generate Art.
    @objc func goButtonPressed(){
       
        pressMeView.stopAnimating()
        progressView.startAnimating()
        goButton.isSelected = false
        goButton.isHidden = true
        DispatchQueue.main.async {
            self.pressMeView.startAnimating()
            self.progressView.stopAnimating()
            self.canvas.generateArt()
            self.goButton.isSelected = true
            self.goButton.isHidden = false
        }
    }
    
    @IBAction func changeComplexity(_ sender: Any) {
        
        canvas.changeDepth(with: Int(slider.value))
    }
    
    @IBAction func saveArt(_ sender: Any) {
    
        pressMeView.isHidden = true
        canvas.layer.borderWidth = 0
        canvas.layer.cornerRadius = 0
        let renderer = UIGraphicsImageRenderer(size: canvas.frame.size)
        let artWork = renderer.image { ctx in
            canvas.drawHierarchy(in: canvas.bounds, afterScreenUpdates: true)
        }
        
        DispatchQueue.global(qos: .background).async {
                  self.store(image: artWork,
                              forKey: "buildingImage",
                              withStorageType: .fileSystem)
                  print("Saved!")
        }
        pressMeView.isHidden = false
        canvas.layer.borderWidth = 3
        canvas.layer.cornerRadius = 5
        UIImageWriteToSavedPhotosAlbum(artWork, self,
            #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo:
        UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription,
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message:
                "Your Artwork has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func store(image: UIImage, forKey key: String, withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                // Save to disk
               if let filePath = filePath(forKey: key) {
                    do  {
                        try pngRepresentation.write(to: filePath,
                                                    options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                UserDefaults.standard.set(pngRepresentation, forKey: key)
            }
        }
    }
    
    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,in:
            FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    // https://www.hackingwithswift.com/books/ios-swiftui/how-to-save-images-to-the-users-photo-library
    }
}
