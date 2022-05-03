//
//  FreeCollectionVC.swift
//  RandomArt
//
//  Modified by Ronald on 4/15/22.
//  Copyright © 2020 Ronald. All rights reserved.
//
//  This is a compilation of some interesting generated wallpapers that the user doesn't need to
//  generate and can download and use. This compilation can be filtered by some tags to make the
//  user search for interesting wallpapers easier.
 
import UIKit
import CoreData

class FreeCollectionVC: UIViewController {

    @IBOutlet weak var artworkCollection: UICollectionView!
    private let WallpaperSize = 45
    private var wallpapers = [Wallpaper]()
    
    private var isVividTagSelected = false
    private var isDarkTagSelected  = false
    private var is50TagSelected  = false
    private var is75TagSelected = false
    private var is100TagSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artworkCollection.delegate = self
        artworkCollection.dataSource = self
        wallpapers = loadWallpapers()
        
        let gesture = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress(_:)))
        artworkCollection.addGestureRecognizer(gesture)
    }
    
    // This will make each wallpaper cell to be draggable.
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        
        switch gesture.state {
            case .began:
                guard let targetIndexPath = artworkCollection.indexPathForItem(at: gesture.location(in: artworkCollection))
                else{
                    return
                }
                artworkCollection.beginInteractiveMovementForItem(at: targetIndexPath)
            case .changed:
                artworkCollection.updateInteractiveMovementTargetPosition(gesture.location(in: artworkCollection))
            case .ended:
                artworkCollection.endInteractiveMovement()
            default:
                artworkCollection.cancelInteractiveMovement()
        }
    }
    
    // This will read all wallpapers from wallpapers.json
    private func loadWallpapers()->[Wallpaper]{
        
        guard let path = Bundle.main.path(forResource: "wallpapers", ofType:"json" ) else {
            print("wallpapers.json not found")
            // TODO: remove assertion when there is a way to handle that file is not found
            assertionFailure("wallpapers.json not found")
            return []
        }
        
        var wallpaperFile: WallpaperFile?
        
        let url = URL(fileURLWithPath: path)
        
        do{
            let jsonData = try Data(contentsOf: url)
            wallpaperFile = try JSONDecoder().decode(WallpaperFile.self, from: jsonData)
            
            if let wallpaperFile = wallpaperFile {
                return wallpaperFile.wallpapers
            }else{
                print("Failed to parse file wallpapers.json")
            }
            
        }catch {
            print("Error: loading file wallpapers.json")
        }
        return []
    }
    
    // This will show wallpapers that are vivid
    @IBAction func showVividWallpapers(_ sender: Any) {
        
        // Switch tag state
        if isVividTagSelected {
            isVividTagSelected = false
        }else {
            isVividTagSelected = true
        }
        applyTag(isSelected: isVividTagSelected, button: sender as? UIButton)
    }
    
    // This will show wallpapers that are dark
    @IBAction func showDarkWallpapers(_ sender: Any) {
        // Switch tag state
        if isDarkTagSelected {
            isDarkTagSelected = false
        }else {
            isDarkTagSelected = true
        }
        applyTag(isSelected: isDarkTagSelected, button: sender as? UIButton)
    }
    
    // This will show wallpapers that have 50% of complexity
    @IBAction func show50PercentComplexity(_ sender: Any) {
        // Switch tag state
        if is50TagSelected {
            is50TagSelected = false
        }else {
            is50TagSelected = true
        }
        applyTag(isSelected: is50TagSelected, button: sender as? UIButton)
    }
    
    // This will show wallpapers that have 75% of complexity
    @IBAction func show75PercentComplexity(_ sender: Any) {
        // Switch tag state
        if is75TagSelected {
            is75TagSelected = false
        }else {
            is75TagSelected = true
        }
        applyTag(isSelected: is75TagSelected, button: sender as? UIButton)
    }
    
    // This will show wallpapers that have 100% of complexity
    @IBAction func show100PercentComplexity(_ sender: Any) {
        // Switch tag state
        if is100TagSelected {
            is100TagSelected = false
        }else {
            is100TagSelected = true
        }
        applyTag(isSelected: is100TagSelected, button: sender as? UIButton)
    }
    
    // This changes the state of the tag from being selected if it is unselected or
    // unselected if it is selected. It then applies the effect of the tag and all the tags that
    // are active to the collection.
    private func applyTag(isSelected: Bool, button:UIButton?){
        
        wallpapers = loadWallpapers()
        if isSelected {
            makeSelected(button: button)
        }else {
            makeUnselected(button: button)
        }
        // Apply filters
        applyFilters()
        artworkCollection.reloadData()
    }
    
    // This applies the effects of all the tags that are active.
    private func applyFilters(){
        // Apply filters
        if isVividTagSelected {
            wallpapers = wallpapers.filter{ $0.isVivid() == true}
        }
        if isDarkTagSelected {
            wallpapers = wallpapers.filter{ $0.isDark() == true}
        }
        if is50TagSelected && !is75TagSelected && !is100TagSelected {
            wallpapers = wallpapers.filter{ $0.getComplexity() == 50}
        }
        if !is50TagSelected && is75TagSelected && !is100TagSelected {
            wallpapers = wallpapers.filter{ $0.getComplexity() == 75}
        }
        if !is50TagSelected && !is75TagSelected && is100TagSelected{
            wallpapers = wallpapers.filter{ $0.getComplexity() == 100}
        }
        if is50TagSelected && is75TagSelected && !is100TagSelected {
            wallpapers = wallpapers.filter{ $0.getComplexity() == 50
                || $0.getComplexity() == 75 }
        }
        if is50TagSelected && !is75TagSelected && is100TagSelected {
            wallpapers = wallpapers.filter{ $0.getComplexity() == 50
                || $0.getComplexity() == 100
            }
        }
        if !is50TagSelected && is75TagSelected && is100TagSelected{
            wallpapers = wallpapers.filter{ $0.getComplexity() == 75
                || $0.getComplexity() == 100
            }
        }
        if is50TagSelected && is75TagSelected && is100TagSelected{
            wallpapers = wallpapers.filter{ $0.getComplexity() == 75
                || $0.getComplexity() == 100 || $0.getComplexity() == 50
            }
        }
    }
    
    // This makes the button look selected
    private func makeSelected(button: UIButton?){
        
        let BUTTONALPHA = 0.2
        if let button = button {
            let textColor = button.titleLabel?.textColor.withAlphaComponent(BUTTONALPHA)
            button.setTitleColor(textColor, for: .normal)
        }
    }
    // This makes the button look unselected
    private func makeUnselected(button: UIButton?){
        if let button = button {
            let textColor = button.titleLabel?.textColor.withAlphaComponent(1)
            button.setTitleColor(textColor, for: .normal)
        }
    }
    
    // This shows the entire content of the wallpaper cell.
    @IBAction func showWallpaper(_ sender: Any) {
        
        let button = sender as! UIButton
        let indexPath = button.tag
        
        let downlaodVC = storyboard?.instantiateViewController(withIdentifier: "downloadVC") as! DownloadVC
        downlaodVC.imageName =   wallpapers[indexPath].getImageName()
        present(downlaodVC, animated: true, completion: nil)
    }
}

extension FreeCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) ->
        Int {
            return wallpapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let wallpaper = wallpapers.remove(at: sourceIndexPath.row)
        wallpapers.insert(wallpaper, at: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
                    as! WallpaperCollectionViewCell
        
        cell.image.image = UIImage(named: wallpapers[indexPath.row].getImageName())
            cell.complexity.text = String(wallpapers[indexPath.row].getComplexity()) + "%"
        cell.name.text = wallpapers[indexPath.row].getName()
        cell.download.tag = indexPath.row
    
     
        if indexPath.row % 5 != 0 {
            cell.name.isHidden = true
            cell.complexity.isHidden = true
        }else{
            cell.name.isHidden = false
            cell.complexity.isHidden = false
        }
        return cell
    }
}

extension FreeCollectionVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let downlaodVC = storyboard?.instantiateViewController(withIdentifier: "downloadVC") as! DownloadVC
        downlaodVC.imageName =  wallpapers[indexPath.row].getImageName()
        downlaodVC.wallpaperName = wallpapers[indexPath.row].getName()
        downlaodVC.complexity = wallpapers[indexPath.row].getComplexity()
        present(downlaodVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = artworkCollection.frame.size.width
        var width = collectionViewWidth
        
        // This will make a more interesting pattern to look at.
        if indexPath.row % 5 != 0 {
            let padding = collectionViewWidth * 0.05
            width = width - padding
            width = width/2.0
        }
  
        // Make the cell a square
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
}
