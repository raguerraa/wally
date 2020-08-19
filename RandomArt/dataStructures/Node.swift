//
//  Node.swift
//  RandomArt
//
//  Created by Owner on 8/15/20.
//  Copyright © 2020 ronald. All rights reserved.
//

import UIKit

class Node<T> {
  var value: T
  var leftChild: Node?
  var rightChild: Node?

  init(value: T) {
    self.value = value
  }
}
