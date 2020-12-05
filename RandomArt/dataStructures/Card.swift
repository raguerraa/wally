//
//  Card.swift
//  RandomArt
//
//  Created by Owner on 8/27/20.
//  Copyright © 2020 ronald. All rights reserved.
//

import UIKit
import MaterialComponents


class Card: MDCCardCollectionCell {

    static let cardWidth: CGFloat = 300;
    let imageView: UIImageView = UIImageView()
    let cardButton1: MDCButton = MDCButton()
    let cardButton2: MDCButton = MDCButton()
    

    
    override func layoutSubviews() {
        
        
        super.layoutSubviews()

        
        imageView.clipsToBounds = true
        if imageView.superview == nil { addSubview(imageView) }
        if cardButton1.superview == nil { addSubview(cardButton1) }
        if cardButton2.superview == nil { addSubview(cardButton2) }

        cardButton1.sizeToFit()
        cardButton2.sizeToFit()
        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: Card.cardWidth,
                                 height: 500)
        imageView.clipsToBounds = true
        cardButton1.frame = CGRect(x: 8,
                                   y: imageView.frame.maxY + 8,
                                   width: cardButton1.frame.width,
                                   height: cardButton1.frame.height)
        cardButton2.frame = CGRect(x: 8,
                                   y: cardButton1.frame.maxY + 8,
                                   width: cardButton2.frame.width,
                                   height: cardButton2.frame.height)
    

        self.setShadowElevation(.cardResting, for: .normal)
        
        // set actual values
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: Card.cardWidth, height: 800)
    }
  
}
