//
//  CanvasV.swift
//  RandomArt
//
//  Render preview and export images from the same expression trees.
//

import UIKit

protocol CanvasVDelegate: AnyObject {
    func updateName(averageColor: Int)
}

/// A read-only snapshot of the expressions used for the displayed wallpaper.
struct WallpaperFormulas: Equatable {
    let red: String
    let green: String
    let blue: String
    let depth: Int
    let definitions: [String]
}

private struct WallpaperEquations {
    let red: MathBinaryTree
    let green: MathBinaryTree
    let blue: MathBinaryTree
    let formulas: WallpaperFormulas

    init(depth: Int) {
        let red = MathBinaryTree(depth: depth)
        let green = MathBinaryTree(depth: depth)
        let blue = MathBinaryTree(depth: depth)
        self.red = red
        self.green = green
        self.blue = blue
        formulas = WallpaperFormulas(
            red: red.formula, green: green.formula, blue: blue.formula, depth: depth,
            definitions: Array(Set(red.formulaDefinitions + green.formulaDefinitions + blue.formulaDefinitions)).sorted()
        )
    }
}

class CanvasV: UIView {
    weak var delegate: CanvasVDelegate?

    private var depth = 6
    private var currentEquations: WallpaperEquations?

    // This changes with the displayed image, not when the next complexity is selected.
    var currentFormulas: WallpaperFormulas? { currentEquations?.formulas }

    private let renderingQueue = DispatchQueue(label: "iwalle.wallpaper.render", qos: .userInitiated)

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.contentsGravity = .resize
    }

    func changeDepth(with depth: Int) {
        self.depth = max(1, depth)
    }

    // Work is done off the main thread. The completion is called only after
    // the newly produced image has been assigned and its layer transaction commits.
    func generateWallpaper(completion: @escaping (Bool) -> Void) {
        layoutIfNeeded()
        let size = bounds.size
        let selectedDepth = depth
        guard size.width > 0, size.height > 0 else {
            completion(false)
            return
        }

        let width = max(1, Int(ceil(size.width)))
        let height = max(1, Int(ceil(size.height)))

        renderingQueue.async { [weak self] in
            let equations = WallpaperEquations(depth: selectedDepth)
            guard let output = Self.render(equations, width: width, height: height) else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            DispatchQueue.main.async {
                guard let self = self else {
                    completion(false)
                    return
                }
                self.currentEquations = equations
                self.delegate?.updateName(averageColor: output.averageColor)
                CATransaction.begin()
                CATransaction.setCompletionBlock { completion(true) }
                self.layer.contents = output.image.cgImage
                CATransaction.commit()
            }
        }
    }

    // Save a fresh high-resolution render, never a screenshot of the preview.
    // Use the original equations so the saved artwork matches what the user saw.
    func exportWallpaper(completion: @escaping (UIImage?) -> Void) {
        guard let equations = currentEquations, bounds.width > 0, bounds.height > 0 else {
            completion(nil)
            return
        }

        let exportWidth = 1170
        let exportHeight = max(1, Int((CGFloat(exportWidth) * bounds.height / bounds.width).rounded()))

        renderingQueue.async {
            let output = Self.render(equations, width: exportWidth, height: exportHeight)
            DispatchQueue.main.async {
                completion(output?.image)
            }
        }
    }

    private static func render(_ equations: WallpaperEquations, width: Int, height: Int)
        -> (image: UIImage, averageColor: Int)? {
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        var redTotal: Int64 = 0
        var greenTotal: Int64 = 0
        var blueTotal: Int64 = 0

        for row in 0..<height {
            let y = Float(row) / Float(height)
            for column in 0..<width {
                let x = Float(column) / Float(width)
                let offset = row * bytesPerRow + column * 4
                let red = UInt8((min(1, max(0, equations.red.evaluateTreeFunction(x: x, y: y))) * 255).rounded())
                let green = UInt8((min(1, max(0, equations.green.evaluateTreeFunction(x: x, y: y))) * 255).rounded())
                let blue = UInt8((min(1, max(0, equations.blue.evaluateTreeFunction(x: x, y: y))) * 255).rounded())
                pixels[offset] = red
                pixels[offset + 1] = green
                pixels[offset + 2] = blue
                pixels[offset + 3] = 255
                redTotal += Int64(red)
                greenTotal += Int64(green)
                blueTotal += Int64(blue)
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue
        let image: CGImage? = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                space: colorSpace, bitmapInfo: bitmapInfo
            ) else { return nil }
            return context.makeImage()
        }
        guard let cgImage = image else { return nil }
        let count = Int64(width * height)
        let r = Int(redTotal / count)
        let g = Int(greenTotal / count)
        let b = Int(blueTotal / count)
        return (UIImage(cgImage: cgImage), (r << 16) | (g << 8) | b)
    }
}
