//
//  canvasView.swift
//  RandomArt
//
//  Created by Owner on 8/18/20.
//  Copyright © 2020 ronald. All rights reserved.
//

import UIKit

class canvasView: UIView {

    let mycont = 0
    let DEPTH:Int = 10

    var color = UIColor.white.cgColor
    var isNotDrawing  = true
    
    var mathTreeRed: MathBinaryTree = MathBinaryTree()
    var mathTreeGreen: MathBinaryTree = MathBinaryTree()
    var mathTreeBlue: MathBinaryTree = MathBinaryTree()
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        //let path = UIBezierPath(ovalIn: rect)
        //UIColor.green.setFill()
        //path.fill()
        
        super.draw(rect)
        if(isNotDrawing){
            return
        }

        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        let widthPoints: Int = Int(ceil(self.frame.width))
        let heightPoints: Int = Int(ceil(self.frame.height))
        
        mathTreeRed.GenerateRandomTree(with: DEPTH)
        mathTreeGreen.GenerateRandomTree(with: DEPTH)
        mathTreeBlue.GenerateRandomTree(with: DEPTH)
        
        let horizontalOffset: Float = 1.0/Float(widthPoints)
        print("Width: ", widthPoints )
        print("Height: ", heightPoints)
        let verticalOffset: Float = 1.0/Float(heightPoints)
        print("shiftx: ", horizontalOffset )
        print("shifty: ", verticalOffset)
        
        var rowShift: Float = 0
        
        for x2 in 1...widthPoints {
            var columnShift: Float = 0
            
            for y2 in 1...heightPoints{
                context.move(to: CGPoint(x: x2-1,y: y2-1))
                
                let red = mathTreeRed.evaluateTreeFunction(x: columnShift, y:rowShift)
                let green = mathTreeGreen.evaluateTreeFunction(x: columnShift, y: rowShift)
                let blue = mathTreeBlue.evaluateTreeFunction(x: columnShift, y: rowShift)
    
                let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue:
                    CGFloat(blue), alpha: 1).cgColor
                
                context.addLine(to: CGPoint(x: x2,y: y2))
                context.setStrokeColor(color)
                context.strokePath()
                
                columnShift = columnShift + horizontalOffset
            }
            rowShift = rowShift + verticalOffset
        }
    }
    
    func generateArt() {
        color = UIColor.red.cgColor
        isNotDrawing = false
        setNeedsDisplay()
    }
}
