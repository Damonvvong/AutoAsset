//
//  Asset.swift
//  AutoAsset
//
//  Created by damonwong on 2018/4/7.
//  Copyright © 2018年 damonwong. All rights reserved.
//

import Foundation

class Asset {
    static let assetPattern = "([\\w\\s]+)@?(.*?)\\.(.+)"
    let filePath: String
    let fileName: String
    var groupName: String = ""
    var scale: String = "1x"
    var exten: String = ""

    static func isAsset(filePath: String) -> Bool {
        if let _ = String(filePath.split(separator: "/").last ?? "").firstMatch(pattern: Asset.assetPattern) {
            return true
        } else {
            return false
        }
    }

    init(filePath: String) {
        self.filePath = filePath
        let filename = String(filePath.split(separator: "/").last ?? "")
        self.fileName = filename
        if let match = filename.firstMatch(pattern: Asset.assetPattern) {
            self.groupName = match[1]
            self.scale = match[2]
            self.exten = match[3]
        }
    }

    var info: [String: Any] {
        return ["idiom": "universal",
                "scale": scale,
                "filename": fileName,
        ]
    }
}
