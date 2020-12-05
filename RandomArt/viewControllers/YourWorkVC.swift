//
//  YourWorkVC.swift
//  RandomArt
//
//  Created by Owner on 8/26/20.
//  Copyright © 2020 ronald. All rights reserved.
//

import UIKit
import CardSlider
import MaterialComponents

class YourWorkVC: UICollectionViewController {

  //TODO: Add an appBarViewController property
  var appBarViewController = MDCAppBarViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureTopBar()
    }
    
    private func configureTopBar(){
        
        self.view.tintColor = .black
        self.view.backgroundColor = .white
        self.title = "Gallery"

        self.collectionView?.backgroundColor = .white

        // AppBar Setup
        //TODO: Add the appBar controller and views
        self.addChild(self.appBarViewController)
        self.view.addSubview(self.appBarViewController.view)
        
        self.appBarViewController.didMove(toParent: self)

        // Set the tracking scroll view.
        self.appBarViewController.headerView.trackingScrollView = self.collectionView
        self.appBarViewController.headerView.minimumHeight = 100

        // Setup Navigation Items
        //TODO: Create the items and set them on the view controller's navigationItems properties
        let menuItemImage = UIImage(named: "MenuItem")
        let templatedMenuItemImage = menuItemImage?.withRenderingMode(.alwaysTemplate)
        let menuItem = UIBarButtonItem(image: templatedMenuItemImage,
                                       style: .plain,
                                       target: self,
                                       action: #selector(menuItemTapped(sender:)))
        self.navigationItem.leftBarButtonItem = menuItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (self.collectionViewLayout is UICollectionViewFlowLayout) {
          let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
          let HORIZONTAL_SPACING: CGFloat = 8.0
          let itemDimension: CGFloat = (self.view.frame.size.width - 3.0 * HORIZONTAL_SPACING) * 0.5
          let itemSize = CGSize(width: itemDimension, height: itemDimension)
          flowLayout.itemSize = itemSize
        }
    }

  //MARK - Methods
    @objc func menuItemTapped(sender: Any) {
        self.sideMenuController?.revealMenu();
    }

    //MARK - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        //TODO: Set the number of cells to be equal to the number of products in the catalog
        return Catalog.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "ProductCell",
                                                            for: indexPath) as! ProductCell
        //TODO: Set the properties of the cell to reflect to product from the model
        let product = Catalog.productAtIndex(index: indexPath.row)
        cell.imageView.image = UIImage(named: product.imageName)
        cell.nameLabel.text = product.productName
        cell.priceLabel.text = product.price

        return cell
    }

}

//MARK: - UIScrollViewDelegate

// The following four methods must be forwarded to the tracking scroll view in order to implement
// the Flexible Header's behavior.

//TODO: Send the scrollView delegate messages to our appBar's headerView
extension YourWorkVC {

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (scrollView == self.appBarViewController.headerView.trackingScrollView) {
      self.appBarViewController.headerView.trackingScrollDidScroll()
    }
  }

  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if (scrollView == self.appBarViewController.headerView.trackingScrollView) {
      self.appBarViewController.headerView.trackingScrollDidEndDecelerating()
    }
  }

  override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                         willDecelerate decelerate: Bool) {
    let headerView = self.appBarViewController.headerView
    if (scrollView == headerView.trackingScrollView) {
      headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
    }
  }

  override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let headerView = self.appBarViewController.headerView
    if (scrollView == headerView.trackingScrollView) {
      headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                               targetContentOffset: targetContentOffset)
    }
  }

}
