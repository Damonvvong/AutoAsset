//
//  StringEx.swift
//  AutoAsset
//
//  Created by damonwong on 2018/4/7.
//  Copyright © 2018年 damonwong. All rights reserved.
//

import Foundation

extension String {
    
    // 正则匹配
    func firstMatch(pattern: String)-> [String]? {
        guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
            let match = regularExpression.firstMatch(in: self, options: [], range: NSMakeRange(0, self.utf16.count)) else {
                return nil
        }
        var matchResults = [String]()
        for i in 0..<match.numberOfRanges {
            if !NSEqualRanges(match.range(at: i), NSMakeRange(NSNotFound, 0)) {
                let lowerBound = match.range(at: i).lowerBound
                let length = match.range(at: i).length
                if length < 0 { continue }
                let start = index(startIndex, offsetBy: lowerBound) //advance(self.startIndex, startIndex)
                let end = index(startIndex, offsetBy: (lowerBound + length)) //advance(self.startIndex, startIndex + length)
                let subString = String(self[start ..< end])
                matchResults.append(subString)
            }
        }
        return matchResults.isEmpty ? nil : matchResults
    }

    // 判断是否是文件夹路径
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: self, isDirectory: &isDirectory) else {
            return isDirectory.boolValue
        }
        return isDirectory.boolValue
    }
}
