//
//  FileError.swift
//  RandomArt
//
//  Created by ronald Guerra on 6/4/23.
//  Copyright © 2023 ronald. All rights reserved.
//

import Foundation

// Custom error type for file-related errors
enum FileError: Error {
    case fileNotFound(String)
    case fileReadError(String)
    case fileParseError(String)
}
