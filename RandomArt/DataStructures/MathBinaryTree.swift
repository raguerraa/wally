//
//  MathBinaryTree.swift
//  RandomArt
//
//  A recursive expression tree that evaluates a mathematical color channel.
//

import Foundation

// The generated expression language. Adding an operation requires an enum case
// and implementations in evaluateTreeHelper(_:x:y:) and describe(_:depth:).
enum MathOperation {
    case x, y
    case multiply, average, divide
    case sine, cosine, tangent, sineTwoPi, cosineTwoPi
    case complement, circle, square, floor, ceiling

    var isBinary: Bool {
        switch self {
        case .multiply, .average, .divide: return true
        default: return false
        }
    }
}

final class MathBinaryTree {
    private let depth: Int
    private let root: Node<MathOperation>

    // Deliberately keep the original generator's operation set to preserve
    // the familiar visual character of existing iWallee wallpapers.
    private static let generatedOperations: [MathOperation] = [
        .multiply, .average, .cosine, .sine
    ]

    init(depth: Int) {
        precondition(depth >= 1, "Expression depth must be positive")
        self.depth = depth
        let operation = Self.generatedOperations.randomElement()!
        self.root = Node(value: operation)
        Self.populate(root, remainingDepth: depth)
    }

    private static func populate(_ node: Node<MathOperation>, remainingDepth: Int) {
        if remainingDepth == 1 {
            if node.value.isBinary {
                node.leftChild = Node(value: .x)
                node.rightChild = Node(value: .y)
            } else {
                node.rightChild = Node(value: Bool.random() ? .x : .y)
            }
            return
        }

        let right = Node(value: generatedOperations.randomElement()!)
        node.rightChild = right
        populate(right, remainingDepth: remainingDepth - 1)

        if node.value.isBinary {
            let left = Node(value: generatedOperations.randomElement()!)
            node.leftChild = left
            populate(left, remainingDepth: remainingDepth - 1)
        }
    }

    func evaluateTreeFunction(x: Float, y: Float) -> Float {
        return evaluateTreeHelper(root, x: x, y: y)
    }

    private func evaluateTreeHelper(_ node: Node<MathOperation>, x: Float, y: Float) -> Float {
        // Child nodes are guaranteed by the generator for each operation.
        func right() -> Float { evaluateTreeHelper(node.rightChild!, x: x, y: y) }
        func left() -> Float { evaluateTreeHelper(node.leftChild!, x: x, y: y) }

        switch node.value {
        case .x: return x
        case .y: return y
        case .multiply: return left() * right()
        case .average: return (left() + right()) / 2
        case .divide:
            let a = left()
            let b = right()
            if b == 0 { return a }
            if a == 0 { return b }
            return min(a, b) / max(a, b)
        case .sine:
            return abs(sin(right() * (depth == 1 ? Float.pi / 2 : Float.pi)))
        case .cosine:
            return abs(cos(right() * (depth == 1 ? Float.pi / 2 : Float.pi)))
        case .tangent: return abs(tan(right() * (Float.pi / 4)))
        case .sineTwoPi: return abs(sin(right() * (2 * Float.pi)))
        case .cosineTwoPi: return abs(cos(right() * (2 * Float.pi)))
        case .complement: return abs(1 - right())
        case .circle: return sqrt(1 + sqrt(right()))
        case .square: return sqrt(right())
        case .floor: return Float(Int(abs(1000 * right()))) / 1000
        case .ceiling:
            let value = right()
            return value >= 1 ? 1 : Float(Int(1000 * value) + 1) / 1000
        }
    }

    /// Describe this same tree; never generate another tree for the formula viewer.
    var formula: String {
        Self.describe(root, depth: depth)
    }

    /// Definitions for the custom operations, included only when they occur.
    var formulaDefinitions: [String] {
        var definitions = Set<String>()
        func visit(_ node: Node<MathOperation>) {
            switch node.value {
            case .divide:
                definitions.insert("ratio(a, b) = a if b = 0; b if a = 0; otherwise min(a, b) / max(a, b).")
            case .ceiling:
                definitions.insert("stepUp1000(t) = 1 if t ≥ 1; otherwise (trunc(1000 × t) + 1) / 1000.")
                definitions.insert("trunc(t) discards the fractional part toward zero.")
            case .floor:
                definitions.insert("trunc(t) discards the fractional part toward zero.")
            default:
                break
            }
            if let left = node.leftChild { visit(left) }
            if let right = node.rightChild { visit(right) }
        }
        visit(root)
        return definitions.sorted()
    }

    // Parentheses preserve the evaluation order at every level of the tree.
    // The trigonometric scale uses the original tree depth, just like evaluation.
    static func describe(_ node: Node<MathOperation>, depth: Int) -> String {
        func right() -> String { describe(node.rightChild!, depth: depth) }
        func left() -> String { describe(node.leftChild!, depth: depth) }
        let trigScale = depth == 1 ? "(π / 2)" : "π"

        switch node.value {
        case .x: return "x"
        case .y: return "y"
        case .multiply: return "(\(left()) × \(right()))"
        case .average: return "((\(left()) + \(right())) / 2)"
        case .divide: return "ratio(\(left()), \(right()))"
        case .sine: return "abs(sin(\(trigScale) × \(right())))"
        case .cosine: return "abs(cos(\(trigScale) × \(right())))"
        case .tangent: return "abs(tan((π / 4) × \(right())))"
        case .sineTwoPi: return "abs(sin((2 × π) × \(right())))"
        case .cosineTwoPi: return "abs(cos((2 × π) × \(right())))"
        case .complement: return "abs(1 - \(right()))"
        case .circle: return "sqrt(1 + sqrt(\(right())))"
        case .square: return "sqrt(\(right()))"
        case .floor: return "(trunc(abs(1000 × \(right()))) / 1000)"
        case .ceiling: return "stepUp1000(\(right()))"
        }
    }
}
