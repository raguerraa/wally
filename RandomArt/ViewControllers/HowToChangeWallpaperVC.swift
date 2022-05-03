//
//  HowToChangeWallpaperVC.swift
//  RandomArt
//
//  Created by ronald Guerra on 4/13/22.
//  Copyright © 2022 ronald. All rights reserved.
//
//  This presents a PDF that shows that user how to change its current wallpaper with one of the
//  generated wallpapers from the app.

import UIKit
import PDFKit

class HowToChangeWallpaperVC: UIViewController {

    let pdfView = PDFView(frame:CGRect(x: 0, y: 0, width: 100, height: 100) )
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePDFView()
        loadHowToChangeWallpaperPDF()
    }
    
    func configurePDFView(){
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
                
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 64).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        
        pdfView.minScaleFactor = 0.1
        pdfView.maxScaleFactor = 5
         
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.layer.cornerRadius = 15
        pdfView.clipsToBounds = true
       
    }
    
    // Load the PDF file, howToChangeWallpapers.pdf and display it.
    func loadHowToChangeWallpaperPDF(){
        
        guard let path = Bundle.main.url(forResource: "howToChangeWallpapers", withExtension: "pdf") else { return }

        if let document = PDFDocument(url: path) {
            pdfView.document = document
        }
    }
}

extension PDFView {

    // Disables the PDFView default bouncing behavior.
    func disableBouncing() {
        for subview in subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.bounces = false
                return
            }
        }
        print("PDFView.disableBouncing: FAILED!")
    }
}
