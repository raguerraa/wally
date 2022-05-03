//
//  DownloadExtension.swift
//  RandomArt
//
//  Created by ronald Guerra on 4/13/22.
//  Copyright © 2022 ronald. All rights reserved.
//
//  This extension is used to save an image to the user's photo library.

import UIKit

enum StorageType {
    case userDefaults
    case fileSystem
}

extension UIViewController {
    
    func saveImage(image: UIImage) {
        DispatchQueue.global(qos: .background).async {
            self.store(image: image,
                              forKey: "buildingImage",
                              withStorageType: .fileSystem)
            print("Saved!")
        }

        UIImageWriteToSavedPhotosAlbum(image, self,
            #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc fileprivate func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo:
        UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error!", message: error.localizedDescription,
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message:
                "Your Wallpaper has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    fileprivate func store(image: UIImage, forKey key: String, withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                // Save to disk
               if let filePath = filePath(forKey: key) {
                    do  {
                        try pngRepresentation.write(to: filePath,
                                                    options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                UserDefaults.standard.set(pngRepresentation, forKey: key)
            }
        }
    }
    
    fileprivate func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,in:
            FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
}
