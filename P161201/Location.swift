//
//  Location.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/6/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import Foundation

enum Location {
    case resources
    case documents
    case cache

    var url: URL {
        let fileManager = FileManager.default
        switch self {
        case .resources:
            return Bundle.main.bundleURL
        case .documents:
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        case .cache:
            return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        }
    }
}
