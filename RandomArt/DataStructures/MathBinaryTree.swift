//
//  MathBinaryTree.swift
//  RandomArt
//
//  Modified by Ronald on 06/04/23.
//  Copyright © 2020 Ronald. All rights reserved.
//
//  This class represents a generator for binary trees that contain math operations on each node,
//  with x or y values on the leaves. The binary tree structure consists of nodes that can contain
//  either unary or binary operations, randomly selected during generation.

import func Darwin.sin
import func Darwin.cos
import func Darwin.tan
import func Darwin.sqrt

class MathBinaryTree {
    
    private var DEPTH = 0
    private var root: Node<String>?
    
    // Supported math operations:
    // If a new math operation is added then it must be added a handling case in the
    // evaluateTreeHelper method.
    private let binaryOperations: [String] = ["*", "avg"]
    private let uniryOperations: [String] = ["cos", "sin"]
    
    // Generates new Math Binary Tree of a given depth.
    func GenerateRandomTree(with depth: Int){
        DEPTH = depth
        if depth == 0 {
            return
        }
        // Create root
        root = Node<String>(value: generateRandomOperation())
        generatorHelper(depth, root!)
    }
    
    private func generatorHelper(_ depth: Int, _ node: Node<String>) {
        // Base case
        if depth == 1 {
            // Add X, Y leaves if it is a binary operation,
            // else add an X or Y leaf
            if binaryOperations.contains(node.value) {
                // Create x, y nodes
                let x = Node<String>(value: "x")
                x.leftChild = nil
                x.rightChild = nil
                let y = Node<String>(value: "y")
                y.leftChild = nil
                y.rightChild = nil
                
                // Add both x, y leaves to the node
                node.leftChild = x
                node.rightChild = y
            } else {
                // Add x or y with 50% possibility each
                if Int.random(in: 0...1) == 0 {
                    let x = Node<String>(value: "x")
                    x.leftChild = nil
                    x.rightChild = nil
                    node.rightChild = x
                    node.leftChild = nil
                } else {
                    let y = Node<String>(value: "y")
                    y.leftChild = nil
                    y.rightChild = nil
                    node.rightChild = y
                    node.leftChild = nil
                }
            }
            return
        }
        
        // Leap of faith:
        // Add two new math operations if it is a binary operation, else only one
        
        let rightNode = Node<String>(value: generateRandomOperation())
        node.rightChild = rightNode
        generatorHelper(depth - 1, rightNode)
        
        if binaryOperations.contains(node.value) {
            let leftNode = Node<String>(value: generateRandomOperation())
            node.leftChild = leftNode
            generatorHelper(depth - 1, leftNode)
        } else {
            node.leftChild = nil
        }
    }
    
    // returns a random math operation.
    private func generateRandomOperation() -> String{
        let dice = Int.random(in: 1...(binaryOperations.count + uniryOperations.count))
        if dice <= binaryOperations.count {
            return binaryOperations[dice - 1]
        }else{
            return uniryOperations[dice - binaryOperations.count - 1]
        }

    }
    // Gets the depth of the tree.
    func getDepth() -> Int {
        return DEPTH
    }
    
    // This method evaluates the randomly generated math expression given 'x' and 'y'.
    // 'x' and 'y' must be numbers from 0 to 1.
    // The result's domain is also from 0 to 1.
    func evaluateTreeFunction(x: Float, y: Float) -> Float {
        guard x >= 0 && x <= 1 && y >= 0 && y <= 1 else {
            fatalError("Input to math function is out of range [0, 1]")
        }

        guard let root = root else {
            return 0
        }
        
        let result = evaluateTreeHelper(node: root, x: x, y: y)
        
        guard result >= 0 && result <= 1 else {
            fatalError("Result is out of range [0, 1]")
        }
        
        return result
    }
    
    // This helper method recursively evaluates the random math expression with the given 'x' and 'y' inputs.
    // When a node contains a unary operation, it is and must be stored in the right child node.
    private func evaluateTreeHelper(node: Node<String>?, x: Float, y: Float) -> Float {
        guard let node = node else {
            return 0
        }
        
        switch node.value {
        case "x":
            return x
        case "y":
            return y
        case "*":
            return evaluateTreeHelper(node: node.rightChild, x: x, y: y) * evaluateTreeHelper(node: node.leftChild, x: x, y: y)
        case "/":
            let leftResult = evaluateTreeHelper(node: node.leftChild, x: x, y: y)
            let rightResult = evaluateTreeHelper(node: node.rightChild, x: x, y: y)
            
            if rightResult == 0 {
                return leftResult
            }
            if leftResult == 0 {
                return rightResult
            }
            if rightResult > leftResult {
                return leftResult / rightResult
            }
            return rightResult / leftResult
        case "sin":
            if DEPTH == 1 {
                return abs(sin(evaluateTreeHelper(node: node.rightChild, x: x, y: y) * (Float.pi / 2)))
            }
            return abs(sin(evaluateTreeHelper(node: node.rightChild, x: x, y: y) * (Float.pi)))
        case "tan":
            return abs(tan(evaluateTreeHelper(node: node.rightChild, x: x, y: y) * (Float.pi / 4)))
        case "cos":
            if DEPTH == 1 {
                return abs(cos(evaluateTreeHelper(node: node.rightChild, x: x, y: y) * (Float.pi / 2)))
            }
            return abs(cos(evaluateTreeHelper(node: node.rightChild, x: x, y: y) * (Float.pi)))
        case "sin2Pi":
            return abs(sin(evaluateTreeHelper(node: node.rightChild, x: x, y: y) * (2 * Float.pi)))
        case "cos2Pi":
            return abs(cos(evaluateTreeHelper(node: node.rightChild, x: x, y: y) * (2 * Float.pi)))
        // The complement math operation whose domain is [0,1] and range [0,1]
        case "com":
            return abs(1 - evaluateTreeHelper(node: node.rightChild, x: x, y: y))
        case "circle":
            return abs((1 + sqrt(evaluateTreeHelper(node: node.rightChild, x: x, y: y))).squareRoot())
        case "square":
            return abs((evaluateTreeHelper(node: node.rightChild, x: x, y: y).squareRoot()))
        case "floor":
            let result = Int(abs(1000 * evaluateTreeHelper(node: node.rightChild, x: x, y: y)))
            return Float(result) / 1000.0
        case "ceiling":
            let result = evaluateTreeHelper(node: node.rightChild, x: x, y: y)
            if result >= 1 {
                return 1
            }
            let choppedPrecision = Int(1000 * result) + 1
            return Float(choppedPrecision) / 1000.0
        case "avg":
            return (evaluateTreeHelper(node: node.rightChild, x: x, y: y) + evaluateTreeHelper(node: node.leftChild, x: x, y: y)) / 2
        default:
            preconditionFailure("Missing handling for a new math operation")
        }
    }
}

