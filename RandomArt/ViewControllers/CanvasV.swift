//
//  canvasV.swift
//  RandomArt
//
//  Modified by Ronald on 06/04/23.
//  Copyright © 2020 Ronald. All rights reserved.
//
//  This generates the wallpaper in the canvas view given the depth of the tree(complexity of
//  the math expresion).

import UIKit

protocol CanvasVDelegate{
    func updateName(averageColor: Int)
}

class CanvasV: UIView {
    
    var delegate: CanvasVC?

    private let mycont = 0
    private var DEPTH:Int = 6

    private var color = UIColor.white.cgColor
    private var isNotDrawing  = true
    
    private var mathTreeRed: MathBinaryTree = MathBinaryTree()
    private var mathTreeGreen: MathBinaryTree = MathBinaryTree()
    private var mathTreeBlue: MathBinaryTree = MathBinaryTree()
    
    // This method generates the wallpaper.
    internal override func draw(_ rect: CGRect) {

        super.draw(rect)

        // Check if drawing is enabled
        if isNotDrawing {
            return
        }

        // Get the current graphics context
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        // Calculate the width and height of the view
        let widthPoints = Int(ceil(frame.width))
        let heightPoints = Int(ceil(frame.height))

        // Generate random math expressions for red, green, and blue channels
        mathTreeRed.GenerateRandomTree(with: DEPTH)
        mathTreeGreen.GenerateRandomTree(with: DEPTH)
        mathTreeBlue.GenerateRandomTree(with: DEPTH)

        // Calculate the horizontal and vertical offsets
        let horizontalOffset: Float = 1.0 / Float(widthPoints)
        let verticalOffset: Float = 1.0 / Float(heightPoints)

        var rowShift: Float = 0

        // Variables to calculate the average color of the wallpaper
        var redAverage = 0
        var greenAverage = 0
        var blueAverage = 0

        // Iterate over each point in the screen
        for y2 in 1...heightPoints {

            var columnShift: Float = 0
            for x2 in 1...widthPoints {
                context.move(to: CGPoint(x: x2 - 1, y: y2 - 1))

                // Evaluate the math expressions for red, green, and blue channels
                let red = mathTreeRed.evaluateTreeFunction(x: columnShift, y: rowShift)
                let green = mathTreeGreen.evaluateTreeFunction(x: columnShift, y: rowShift)
                let blue = mathTreeBlue.evaluateTreeFunction(x: columnShift, y: rowShift)

                let red255 = Int(red * 255)
                let green255 = Int(green * 255)
                let blue255 = Int(blue * 255)

                redAverage += red255
                greenAverage += green255
                blueAverage += blue255

                let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1).cgColor

                context.addLine(to: CGPoint(x: x2, y: y2))
                context.setStrokeColor(color)
                context.strokePath()

                columnShift += horizontalOffset
            }
            rowShift += verticalOffset
        }

        // Calculate the average color and convert it to hexadecimal
        let totalPoints = widthPoints * heightPoints
        let redHex = String(format: "%02X", redAverage / totalPoints)
        let greenHex = String(format: "%02X", greenAverage / totalPoints)
        let blueHex = String(format: "%02X", blueAverage / totalPoints)

        // Convert the hexadecimal color to decimal
        guard let decimalRGB = Int(redHex + greenHex + blueHex, radix: 16) else {
            preconditionFailure("Hexadecimal could not be converted to Decimal")
        }

        // Update the name of the wallpaper using the average color
        delegate?.updateName(averageColor: decimalRGB)
    }
    // This generates the wallpaper. It does so by overriding the drawing method.
    func generateWallpaper() {
        isNotDrawing = false
        setNeedsDisplay()
    }
    // This changes the depth of the tree
    func changeDepth(with depth: Int) {
        DEPTH = depth
    }
}
