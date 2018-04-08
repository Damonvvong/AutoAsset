//
//  AssetGroup.swift
//  AutoAsset
//
//  Created by damonwong on 2018/4/7.
//  Copyright © 2018年 damonwong. All rights reserved.
//

import Foundation

class AssetGroup {
    let name: String
    let groupPath: String
    var assets: [Asset] = []

    var imagesetDirectory: String {
        return groupPath + name + ".imageset"
    }

    var imagesetInfoFilePath: String {
        return imagesetDirectory + "/Contents.json"
    }


    init(name: String,groupPath: String) {
        self.name = name
        self.groupPath = groupPath
    }

    func remove() {
        if FileManager.default.fileExists(atPath: imagesetDirectory) {
            try? FileManager.default.removeItem(atPath: imagesetDirectory)
        }
    }

    var info: [String: Any] {
        var info: [String: Any] = ["images": [["idiom" : "universal","scale" : "1x"]],
                                    "info":["version": "1","author": "xcode"]]
        guard var images = info["images"] as? [[String: Any]] else {
            return info
        }
        for asset in assets {
            images.append(asset.info)
        }
        info["images"] = images
        return info
    }
}
