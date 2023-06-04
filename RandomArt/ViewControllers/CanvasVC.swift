//
//  CanvasVC.swift
//  RandomArt
//
//  Modified by Ronald on 06/04/23.
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

    var sideMenu: SideBarMenuVC?
    
    @IBOutlet weak var complexityPercentage: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var canvas: CanvasV!
    
    @IBOutlet weak var colorAdjective: UILabel!
    @IBOutlet weak var artNoun: UILabel!
    
    @IBOutlet weak var pressMeView: NVActivityIndicatorView!
    @IBOutlet weak var progressView: NVActivityIndicatorView!
    
    @IBOutlet weak var topBar: UIStackView!
    
    private var appBarViewController = UINavigationController()
    private let goButton = UIButton()
    
    private var currentWallpaper: UIImage?
    private var colors:[Color] = []
    private var artNames:[String] = [String]()

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .black
        
        configureCanvas()
        configureGoButton()
        pressMeView.startAnimating()
        
        // If it returns nil, then we display a default color adjective.
        let colorError = Color(name: "Absolute", decimal: 0)
        do {
            colors = try readColorWordsFile()
        } catch {
            colors = [colorError]
        }
        
        // If it returns nil, then we display a default art name noun.
        do {
            artNames = try readArtWordsFile()
        } catch {
            artNames = ["Wallpaper"]
        }
        canvas.delegate = self
    }
    
    // This method reads the files that contains the names of colors and positive words
    // so that we can use them to form the names of the wallpapers.It throws a FileError if 
    // there was an error while reading the file.
    private func readColorWordsFile() throws -> [Color] {
        var colors: [Color] = []
        
        // Find the file path for "colorsDb.txt" in the app's bundle
        guard let filepath = Bundle.main.path(forResource: "colorsDb", ofType: "txt") else {
            throw FileError.fileNotFound("colorsDb.txt")
        }
        
        do {
            // Read the contents of the file
            let contents = try String(contentsOfFile: filepath)
            
            // Split the contents by new lines
            let lines = contents.split(separator: "\r\n")
            
            for line in lines {
                // Split each line by the first space
                let components = line.split(separator: " ", maxSplits: 1).map(String.init)
                
                // Extract the decimal value
                let decimal = Int(components[0]) ?? 0
                
                // Extract the name and capitalize it
                let name = String(components[1].dropFirst(2)).capitalized
                
                // Create a Color object and add it to the colors array
                let color = Color(name: name, decimal: decimal)
                colors.append(color)
            }
            
            return colors
        } catch {
            throw FileError.fileReadError(filepath)
        }
    }
    
    // This method loads the file that contains art words and returns a list of them. If
    // there is an error while reading the file, it throws an error.
    private func readArtWordsFile() throws -> [String] {
        guard let filepath = Bundle.main.path(forResource: "artWords", ofType: "txt") else {
            throw FileError.fileNotFound("artWords.txt")
        }
        
        do {
            let contents = try String(contentsOfFile: filepath)
            // Parse the string by new line
            let lines = contents.split(separator: "\r\n").map(String.init)
            
            return lines
        } catch {
            throw FileError.fileReadError(filepath)
        }
    }
    
    // This method binary search in the color file, colorsDB.txt, for a similar color to the
    // given decimal color.
    private func binarySearchSimilarColor(colors:[Color], colorDecimal:Int) -> Color{
        return binarySearchHelper(colors: colors, low: 0, high: colors.count-1, colorDecimal: colorDecimal)
    }
    
    // This is a helper method that performs the actual binary search algorithm to
    // look for a similar color in the file colorsDB.txt
    private func binarySearchHelper(colors: [Color], low: Int, high: Int, colorDecimal: Int) -> Color {
        // Base case: low index is equal to or exceeds high index
        if low >= high {
            return colors[low]
        }
        
        let med = (low + high) / 2 // Calculate the midpoint
        
        // Check if the color at the midpoint matches the target color
        if colors[med].decimal == colorDecimal {
            return colors[med]
        } else if colors[med].decimal > colorDecimal {
            // If the color is greater than the target color, search the left half
            return binarySearchHelper(colors: colors, low: low, high: med - 1, colorDecimal: colorDecimal)
        } else {
            // If the color is less than the target color, search the right half
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
    
    // This enables user interactions
    private func enableUserInteractions(){
        view.isUserInteractionEnabled = true
    }
    
    // This disables user interactions
    private func disableUserInteractions(){
        view.isUserInteractionEnabled = false
    }

    // This shows the side menu.
    @IBAction func menuItemTap(_ sender: Any) {
        disableUserInteractions()
        sideMenuController?.revealMenu()
        enableUserInteractions()
    }
    
    // This configures the button that generates the wallpaper.
    private func configureGoButton() {
        let buttonSize: CGFloat = 80 // Size of the button
        let buttonMargin: CGFloat = 130 // Margin from the canvas
        
        // Set the frame of the button
        goButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Add the button to the view and disable autoresizing mask
        view.addSubview(goButton)
        goButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints for the button
        let constraints = [
            goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center the button horizontally
            goButton.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -buttonMargin), // Position the button above the canvas with the specified margin
            goButton.widthAnchor.constraint(equalToConstant: buttonSize), // Set the width of the button
            goButton.heightAnchor.constraint(equalToConstant: buttonSize) // Set the height of the button
        ]
        NSLayoutConstraint.activate(constraints)
        
        // Round the corners of the button
        goButton.layer.cornerRadius = 0.5 * goButton.bounds.size.width
        goButton.clipsToBounds = true
        
        // Set the button's appearance
        goButton.backgroundColor = UIColor(white: 1, alpha: 0) // Transparent background color
        goButton.layer.borderWidth = 2 // Border width
        goButton.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor // Border color
        goButton.setTitleColor(UIColor.blue, for: .normal) // Text color
        
        // Add a target for button press event
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
    }
    
    // This method generates a wallpaper.
    @objc func goButtonPressed() {
        goButton.isHidden = true
        pressMeView.stopAnimating()
        progressView.startAnimating()
        
        let dispatchGroup = DispatchGroup()
         
         // Enter the dispatch group before starting the wallpaper generation
         dispatchGroup.enter()
         
         DispatchQueue.main.async {
             self.canvas.generateWallpaper()
             
             // Notify the dispatch group that the generation is complete
             dispatchGroup.leave()
         }
         
         dispatchGroup.notify(queue: DispatchQueue.main) {
             // Resume animation and show the go button once generation is complete
             self.pressMeView.startAnimating()
             self.progressView.stopAnimating()
             self.goButton.isHidden = false
         }
     }
    
    // This method changes the complexity of the wallpaper based on the slider value.
    // The complexity is represented by the depth of the MathBinaryTree, which can
    // range from 1 to 11.
    @IBAction func changeComplexity(_ sender: Any) {
        let portion = slider.value - slider.minimumValue
        let range = slider.maximumValue - slider.minimumValue
        
        let percent = (portion / range) * 100.0
        complexityPercentage.text = String(format: "%.1f", percent) + "%"
        canvas.changeDepth(with: Int(slider.value))
    }
    
    // This method takes a screenshot of the entire screen and returns the image.
    func renderImage() -> UIImage {
        
        // Hide all the elements present in the canvas view before rendering the image
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
        
        // Unhide all the elements present in the canvas view after rendering the image
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
    func updateName(averageColor: Int) {
        
        let color = binarySearchSimilarColor(colors: colors, colorDecimal: averageColor)

        colorAdjective.text = color.name
        
        // Set the default if there is an error while findig a random color noun.
        if let randomName = artNames.randomElement() {
            artNoun.text = randomName
        }else {
            artNoun.text = "Wallpaper"
        }
    }
}
