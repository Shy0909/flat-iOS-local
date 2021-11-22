//
//  String+SplitSpecificLength.swift
//  Flat
//
//  Created by xuyunshi on 2021/11/22.
//  Copyright © 2021 agora.io. All rights reserved.
//

import Foundation

extension String {
    // 9999999999 -> 999 999 9999
    public func split(every: Int, backwards: Bool = false) -> [String] {
        var result = [String]()

        for i in stride(from: 0, to: self.count, by: every) {
            switch backwards {
            case true:
                let endIndex = self.index(self.endIndex, offsetBy: -i)
                let startIndex = self.index(endIndex, offsetBy: -every, limitedBy: self.startIndex) ?? self.startIndex
                let realOffset = endIndex.utf16Offset(in: self) - startIndex.utf16Offset(in: self)
                if realOffset < every {
                    let orphan = String(self[startIndex..<self.endIndex])
                    if let last = result.last {
                        result[result.endIndex - 1] = last + orphan
                        return result
                    } else {
                        return [orphan]
                    }
                } else {
                    result.insert(String(self[startIndex..<endIndex]), at: 0)
                }
            case false:
                let startIndex = self.index(self.startIndex, offsetBy: i)
                let endIndex = self.index(startIndex, offsetBy: every, limitedBy: self.endIndex) ?? self.endIndex
                let realOffset = endIndex.utf16Offset(in: self) - startIndex.utf16Offset(in: self)
                if realOffset < every {
                    let orphan = String(self[startIndex..<self.endIndex])
                    if let last = result.last {
                        result[result.endIndex - 1] = last + orphan
                        return result
                    } else {
                        return [orphan]
                    }
                } else {
                    result.append(String(self[startIndex..<endIndex]))
                }
            }
        }

        return result
    }
}
