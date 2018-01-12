//
//  ArrayExtensions.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/9/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import Foundation

// Source: https://stackoverflow.com/a/27261991/4146322

extension Array {
    func shuffled() -> Array {
        var copy = self
        let count = copy.count
        copy.indices.lazy.dropLast().forEach {
            guard case let index = Int(arc4random_uniform(UInt32(count - $0))) + $0, index != $0 else { return }
            copy.swapAt($0, index)
        }
        return copy
    }
    func getRandomValues(limit: Int) -> Array {
        if limit > 0 && limit < self.count {
            return Array(self.shuffled().prefix(limit))
        } else {
            return self
        }
    }
}
