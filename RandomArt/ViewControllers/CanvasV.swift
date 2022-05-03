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

        var redFrequency = [Int: Int]()
        var greenFrequency = [Int: Int]()
        var blueFrequency = [Int: Int]()
 
        
        super.draw(rect)
        if(isNotDrawing){
            return
        }

        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        
        let widthPoints: Int = Int(ceil(self.frame.width))
        let heightPoints: Int = Int(ceil(self.frame.height))
        // TODO: delete when releasing app
        print("Width: ", widthPoints )
        print("Height: ", heightPoints)
        
        // Get a random math expression.
        mathTreeRed.GenerateRandomTree(with: DEPTH)
        mathTreeGreen.GenerateRandomTree(with: DEPTH)
        mathTreeBlue.GenerateRandomTree(with: DEPTH)
        mathTreeRed.printTree()
        
        // We will normalize the x and y coordinates to be in the range [0, 1]
        let horizontalOffset: Float = 1.0/Float(widthPoints)
        let verticalOffset: Float = 1.0/Float(heightPoints)

        var rowShift: Float = 0
        
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
                
                
                if  redFrequency[red255] != nil {
                    redFrequency[red255] = redFrequency[red255]! +  1
                }else{
                    redFrequency[red255] = 1
                }
                if greenFrequency[green255] != nil {
                    greenFrequency[green255] = greenFrequency[green255]! + 1
                }else{
                    greenFrequency[green255] = 1
                }
                if blueFrequency[blue255] != nil {
                    blueFrequency[blue255] = blueFrequency[blue255]! + 1
                }else{
                    blueFrequency[blue255] = 1
                }
                
                let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue:
                    CGFloat(blue), alpha: 1).cgColor
                
                context.addLine(to: CGPoint(x: x2,y: y2))
                context.setStrokeColor(color)
                context.strokePath()

                columnShift = columnShift + horizontalOffset
            }
            rowShift = rowShift + verticalOffset
        }
        // Let's calculate the mode of each color, and find the most common color.
        let redMode = redFrequency.max{a, b in a.value < b.value}
        let greenMode = greenFrequency.max{a, b in a.value < b.value}
        let blueMode = blueFrequency.max{a, b in a.value < b.value}

        if redMode!.key < 0 || redMode!.key > 255 {
            print(redMode!.key)
            assertionFailure("redMode has gone out of bounds")
        }
        if greenMode!.key < 0 || greenMode!.key > 255 {
            print(greenMode!.key)
            assertionFailure("greenMode has gone out of bounds")
        }
        if blueMode!.key < 0 || blueMode!.key > 255 {
            print(blueMode!.key)
            assertionFailure("redMode has gone out of bounds")
        }
        let red = String(format: "%02X", Int(redMode!.key))
        let green = String(format: "%02X", Int(greenMode!.key))
        let blue = String(format: "%02X", Int(blueMode!.key))
        
        // TODO: delete when releasing app
        print("Color avarage hex",red + green + blue)
        //print("Color avarage decimal", Int(red + green + blue, radix: 16))
        
        // Once the wallpaper is generated, let's update the name of the wallpaper.
        delegate?.updateName(avarageColor: Int(red + green + blue, radix: 16) ?? 1 )
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
