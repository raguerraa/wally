//
//  canvasV.swift
//  RandomArt
//
//  Modified by Ronald on 4/15/22.
//  Copyright © 2020 Ronald. All rights reserved.
//
//  This generates the wallpaper in the canvas view given the depth of the tree(complexity of
//  the math expresion).

import UIKit

protocol CanvasVDelegate{
    func updateName(avarageColor: Int)
}

class CanvasV: UIView {
    
    var delegate: CanvasVC?

    let mycont = 0
    var DEPTH:Int = 6

    var color = UIColor.white.cgColor
    var isNotDrawing  = true
    
    var mathTreeRed: MathBinaryTree = MathBinaryTree()
    var mathTreeGreen: MathBinaryTree = MathBinaryTree()
    var mathTreeBlue: MathBinaryTree = MathBinaryTree()
    
    // This generates the wallpaper.
    override func draw(_ rect: CGRect) {
 
        super.draw(rect)
        if(isNotDrawing){
            return
        }

        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        
        let widthPoints: Int = Int(ceil(self.frame.width))
        let heightPoints: Int = Int(ceil(self.frame.height))

        // Get a random math expression.
        mathTreeRed.GenerateRandomTree(with: DEPTH)
        mathTreeGreen.GenerateRandomTree(with: DEPTH)
        mathTreeBlue.GenerateRandomTree(with: DEPTH)
        
        // We will normalize the x and y coordinates to be in the range [0, 1]
        let horizontalOffset: Float = 1.0/Float(widthPoints)
        let verticalOffset: Float = 1.0/Float(heightPoints)

        var rowShift: Float = 0
        
        // We will take the avarage of each color to name the wallpaper
        var redAvarage = 0
        var greenAvarage = 0
        var blueAvarage = 0
        
        // For each point in the screen, we will evaluate the generated random math expression
        // based on its y and x position.
        for y2 in 1...heightPoints {
            
            var columnShift: Float = 0
            for x2 in 1...widthPoints{
                context.move(to: CGPoint(x: x2-1,y: y2-1))
  
                let red = mathTreeRed.evaluateTreeFunction(x: columnShift, y:rowShift)
                let green = mathTreeGreen.evaluateTreeFunction(x: columnShift, y: rowShift)
                let blue = mathTreeBlue.evaluateTreeFunction(x: columnShift, y: rowShift)
                
                let red255:Int  = Int(red*255)
                let green255:Int = Int(green*255)
                let blue255:Int = Int(blue*255)
                
                redAvarage = redAvarage + red255
                greenAvarage = greenAvarage + green255
                blueAvarage = blueAvarage + blue255

                let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue:
                    CGFloat(blue), alpha: 1).cgColor
                
                context.addLine(to: CGPoint(x: x2,y: y2))
                context.setStrokeColor(color)
                context.strokePath()

                columnShift = columnShift + horizontalOffset
            }
            rowShift = rowShift + verticalOffset
        }
        
        // Let's caculate the avarage of each color and change the base to hexadecimal.
        let red = String(format: "%02X", redAvarage/(widthPoints*heightPoints))
        let green = String(format: "%02X", greenAvarage/(widthPoints*heightPoints))
        let blue = String(format: "%02X", blueAvarage/(widthPoints*heightPoints))
        
        // Once the wallpaper is generated, let's update the name of the wallpaper.
        let decimalRGB = Int(red + green + blue, radix: 16)
        guard let decimalRGB = decimalRGB else{
            preconditionFailure("Hexadecimal could be converted to Decimal")
        }
        delegate?.updateName(avarageColor: decimalRGB)
        
    }
    // This generates the wallpaper. It does so by overriding the drawing method.
    func generateWallpaper() {
        isNotDrawing = false
        setNeedsDisplay()
    }
    // This changes the depth of the tree
    func changeDepth(with depth: Int){
        DEPTH = depth
    }
}
