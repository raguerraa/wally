//
//  Node.swift
//  RandomArt
//
//  Modified by Ronald on 4/15/22.
//  Copyright © 2020 Ronald. All rights reserved.
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
