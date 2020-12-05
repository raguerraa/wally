/*
 Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

class Product: NSObject {
  public private(set) var imageName: String
  public private(set) var productName: String
  public private(set) var price: String
  public private(set) var category: String
  public private(set) var isFeatured: Bool

  required init(imageName: String, productName: String, price: String, category: String, isFeatured: Bool) {
    self.imageName = imageName
    self.productName = productName
    self.price = price
    self.category = category
    self.isFeatured = isFeatured
    super.init()
  }
}

class Catalog: NSObject {
  // Notification that gets posted when categoryFilter is changed
  public static let CatalogFilterDidChangeNotification: Notification.Name =
      Notification.Name(rawValue: "CatalogFilterDidChangeNotification")

  private static let products = [
    Product(imageName: "snake", productName: "Vagabond sack", price: "$120", category: "Accessories", isFeatured:true),
    Product(imageName: "smile", productName: "Stella sunglasses", price: "$58", category: "Accessories", isFeatured:true),
    Product(imageName: "blues", productName: "Whitney belt", price: "$35", category: "Accessories", isFeatured:false),
  ]

  private static var filteredProducts: [Product] = products

  static var count: Int {
    return Catalog.filteredProducts.count
  }

  public static func productAtIndex(index: Int) -> Product {
    return Catalog.filteredProducts[index]
  }

  static var categoryFilter: String = "" {
    didSet(newFilter) {
      self.applyFilter()
      NotificationCenter.default.post(name: CatalogFilterDidChangeNotification, object: nil)
    }
  }

  class func applyFilter() {
    self.filteredProducts.removeAll()
    for product in self.products {
      if (self.categoryFilter == "" || self.categoryFilter == "Featured") && product.isFeatured {
        self.filteredProducts.append(product)
      } else if product.category == self.categoryFilter {
        self.filteredProducts.append(product)
      }
    }
  }
}
