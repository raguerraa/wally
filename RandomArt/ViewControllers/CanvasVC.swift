//
//  LandingPageVC.swift
//  RandomArt
//
//  Modified by Ronald on 4/15/22.
//  Copyright © 2020 Ronald. All rights reserved.
//
//  This presents the canvas view controller where we will generate the wallpaper.

import UIKit
import CoreGraphics
import SideMenuSwift
import NVActivityIndicatorView

struct Color{
    // the name of the color
    let name: String
    // the decimal representation of the hexadecimal color
    let decimal: Int
}

class CanvasVC: UIViewController {

    var sideMenu: SideMenuVC?
    
    @IBOutlet weak var complexityPercentage: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var canvas: CanvasV!
    
    @IBOutlet weak var colorAdjective: UILabel!
    @IBOutlet weak var artNoun: UILabel!
    
    @IBOutlet weak var pressMeView: NVActivityIndicatorView!
    @IBOutlet weak var progressView: NVActivityIndicatorView!
    
    @IBOutlet weak var topBar: UIStackView!
    
    var appBarViewController = UINavigationController()
    let goButton = UIButton()
    
    var currentWallpaper: UIImage?
    var colors:[Color] = []
    var artNames:[String] = [String]()

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .black
        configureCanvas()
        configureGoButton()
        pressMeView.startAnimating()
        colors = readColorWordsFile()
        artNames = readArtWordsFile()
        canvas.delegate = self
    }
    
    // This method reads the files that contains the names of colors and positive words
    // so that we can use them to form the names of the wallpapers.
    private func readColorWordsFile() -> [Color]{
        
        var colors:[Color] = []
        
        // Read list of colors ordered by hexadecimal
        if let filepath = Bundle.main.path(forResource: "colorsDb", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                
                // Parse the string by new line
                let lines = contents.split(separator: "\r\n")
                
                for i in 0..<lines.count {
                    
                    var name = ""
                    var decimal = 0
                    // Parse each new line by first space
                    let line = lines[i].split(separator: " ", maxSplits: 1).map(String.init)
                    
                    decimal = Int(line[0]) ?? 0
                    
                    name = String(line[1].dropFirst(2))
                    name = name.capitalized
                    let color  = Color(name: name, decimal: decimal)
                    colors.append(color)
                }
                return colors
            } catch {
                print("File colorsDb.txt contents could not be loaded")
            }
        } else {
            print("colorsDb.txt not found!")
        }
        return []
    }
    
    // This method loads the file that containes art words and returns a list of them.
    private func readArtWordsFile() -> [String]{
        if let filepath = Bundle.main.path(forResource: "artWords", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                // Parse the string by new line
                let lines = contents.split(separator: "\r\n").map(String.init)
                
                return lines
                
            }catch{
                print("File artWords.txt content could not be loaded")
            }
        }else{
            print("artWords.txt not found!")
        }
        return []
    }
    
    // This method binary search in the color file, colorsDB.txt, for a similar color to the
    // given decimal color.
    private func binarySearchSimilarColor(colors:[Color], colorDecimal:Int)->Color{
        return binarySearchHelper(colors: colors, low: 0, high: colors.count-1, colorDecimal: colorDecimal)
    }
    
    // This is a helper method that performs the actual binary search algorithm to
    // look for a similar color in the file colorsDB.txt
    private func binarySearchHelper(colors:[Color], low: Int, high: Int, colorDecimal:Int)->Color{
        
        if (low >= high) {
            // TODO: Delelte when releasing of the app
            print("index = ", low)
            return colors[low]
        }
        let med = (low + high)/2
        if colors[med].decimal == colorDecimal {
            return colors[med]
        }else if colors[med].decimal > colorDecimal{
            return binarySearchHelper(colors: colors, low: low, high: med - 1, colorDecimal: colorDecimal)
        }else {
            return binarySearchHelper(colors: colors, low: med + 1, high: high, colorDecimal: colorDecimal)
        }
    }
    
    // This configures the canvas view.
    private func configureCanvas(){
        canvas.layer.borderWidth = 0
        canvas.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        canvas.layer.cornerRadius = 0
        canvas.clipsToBounds = true
    }

    // This shows the side menu.
    @IBAction func menuItemTap(_ sender: Any) {
        self.sideMenuController?.revealMenu()
    }
    
    // This configures the button that generates the wallpaper.
    private func configureGoButton(){
        
        goButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        view.addSubview(goButton)
        goButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           goButton.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -130),
                           goButton.widthAnchor.constraint(equalToConstant: 80),
                           goButton.heightAnchor.constraint(equalToConstant: 80)
                           ]
        NSLayoutConstraint.activate(constraints)
        goButton.layer.cornerRadius = 0.5 * goButton.bounds.size.width
        goButton.clipsToBounds = true
        
        goButton.backgroundColor = UIColor(white: 1, alpha: 0)
        goButton.layer.borderWidth = 2
        goButton.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
                
        goButton.setTitleColor(UIColor.blue, for: .normal)
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
    }
    
    // This method generate a wallpaper.
    @objc func goButtonPressed(){
       
        pressMeView.stopAnimating()
        progressView.startAnimating()
        goButton.isSelected = false
        goButton.isHidden = true
        
        DispatchQueue.main.async {
            self.pressMeView.startAnimating()
            self.progressView.stopAnimating()
            self.canvas.generateWallpaper()
            self.goButton.isSelected = true
            self.goButton.isHidden = false
        }
    }
    
    // This changes the complexity of the wallpaper.
    // The complexity of the wallpaper is the depth of the MathBinaryTree. The minimum depth of a
    // MathBinaryTree can be 1 and the maximum depth of a MathBinaryTree is 11.
    @IBAction func changeComplexity(_ sender: Any) {
        let portion = slider.value - slider.minimumValue
        let range = slider.maximumValue - slider.minimumValue
        
        let percent = (portion/range) * 100.0
        complexityPercentage.text = String(format:"%.1f", percent) + "%"
        canvas.changeDepth(with: Int(slider.value))
    }
    
    // This method takes a screenshot of the entire screen and returns the image.
    func renderImage() -> UIImage {
        
        // Let's take a screenshot of the background image
        
        // First, let's hide all the elements present in the canvas view
        pressMeView.isHidden = true
        topBar.isHidden = true
        complexityPercentage.isHidden = true
        colorAdjective.isHidden = true
        artNoun.isHidden = true
        
        // Render the image
        let renderer = UIGraphicsImageRenderer(size: canvas.frame.size)
        let artWork = renderer.image { ctx in
            canvas.drawHierarchy(in: canvas.bounds, afterScreenUpdates: true)
        }
        
        // Then, let's unhide all the elements present in the canvas view
        pressMeView.isHidden = false
        topBar.isHidden = false
        complexityPercentage.isHidden = false
        colorAdjective.isHidden = false
        artNoun.isHidden = false
        
        return artWork
    }
   
    // This method saves the wallpaper to the user's photo library.
    @IBAction func saveWallpaper(_ sender: Any) {
        let artWork = renderImage()
        saveImage(image: artWork)
    }
}
extension CanvasVC: CanvasVDelegate {
    func updateName(avarageColor: Int) {
        let color = binarySearchSimilarColor(colors: colors, colorDecimal: avarageColor)
        print("color chosen name:", color.name)
        print("color chosen decimal:", color.decimal)
        colorAdjective.text = color.name
        
        if let randomName = artNames.randomElement() {
            artNoun.text = randomName
        }else {
            artNoun.text = "Wallpaper"
        }
        print("==============>")
        
        // Let's update profile picture image to match the one generated by the canvas
        /*
        let sideMenuVC  = sideMenuController?.menuViewController as? SideMenuVC
        DispatchQueue.main.async { [weak self] in
            sideMenuVC?.profileView.image = self?.renderImage()
        }*/
    }
}
