//
//  Wallpaper.swift
//  RandomArt
//
//  Modified by Ronald on 4/15/22.
//  Copyright © 2020 Ronald. All rights reserved.
//

import Foundation

struct Wallpaper: Decodable {
    
    private var complexity: Int = 0
    private var name = String()
    private var imageName = String()
    private var delightful = true
    private var vivid = true
    private var dark = true
    private var mystical = true
    private var weird = true
    
    
    init(name: String, imageName: String, complexity: Int = 0){
        
        self.name = name
        self.complexity = complexity
        self.imageName = imageName
    }
    func getName() -> String{
        return name
    }
    func getComplexity() -> Int{
        return complexity
    }
    func getImageName() -> String{
        return imageName
    }
    func isDelightful() -> Bool {
        return delightful
    }
    func isVivid() -> Bool {
        return vivid
    }
    func isDark() -> Bool {
        return dark
    }
    func isMystical() -> Bool {
        return mystical
    }
    func isWeird() -> Bool {
        return weird
    }
}
