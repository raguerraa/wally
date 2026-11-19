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

// A completion-based interface also lets tests simulate a slow or failed save
// without creating real photos or showing a system permission prompt.
protocol PhotoLibrarySaving {
    func save(_ image: UIImage, completion: @escaping (Error?) -> Void)
}

final class PhotoLibrarySaver: NSObject, PhotoLibrarySaving {
    static let shared = PhotoLibrarySaver()

    private final class SaveContext {
        let completion: (Error?) -> Void

        init(completion: @escaping (Error?) -> Void) {
            self.completion = completion
        }
    }

    func save(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        // UIKit returns contextInfo in its callback. Retain this request's
        // completion until that callback, then release it exactly once.
        let context = Unmanaged.passRetained(SaveContext(completion: completion)).toOpaque()
        UIImageWriteToSavedPhotosAlbum(
            image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), context
        )
    }

    @objc private func image(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        guard let contextInfo = contextInfo else { return }
        let context = Unmanaged<SaveContext>.fromOpaque(contextInfo).takeRetainedValue()
        context.completion(error)
    }
}

extension UIViewController {
    
    // Completion means Photos has finished (success OR failure), not just
    // that an export image exists. Existing gallery callers can omit it.
    func saveImage(
        image: UIImage,
        using saver: PhotoLibrarySaving = PhotoLibrarySaver.shared,
        completion: (() -> Void)? = nil
    ) {
        saver.save(image) { [weak self] error in
            // Normalize callback delivery before touching controls or alerts.
            DispatchQueue.main.async {
                completion?()
                guard let self = self else { return }

                let alert: UIAlertController
                if let error = error {
                    alert = UIAlertController(
                        title: "Save error!", message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                } else {
                    alert = UIAlertController(
                        title: "Saved!", message: "Your Wallpaper has been saved to your photos.",
                        preferredStyle: .alert
                    )
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // This methods saves the image to the file system or the user defaults.
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
    // This method creates a file path with the name, key, for the image.
    fileprivate func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,in:
            FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
}
