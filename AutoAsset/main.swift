//
//  main.swift
//  AutoAsset
//
//  Created by damonwong on 2018/4/7.
//  Copyright © 2018年 damonwong. All rights reserved.
//

import Foundation

/// MARK: Validate 参数
guard CommandLine.argc == 4 else {
    print("使用指南: AutoAsset [资源同步盘路径] [资源同步盘备份路径] [.xcassets 文件路径]")
    exit(1)
}

let inputPath = CommandLine.arguments[1]
let inputBackPath = CommandLine.arguments[2]
let outputAssetsFilePath = CommandLine.arguments[3]

guard FileManager.default.fileExists(atPath: inputPath) else {
    print("资源同步盘路径 \(inputPath) 不存在")
    // 如果没有资源同步盘路径，那么就正常退出，不进行同步操作
    exit(0)
}

if !FileManager.default.fileExists(atPath: inputBackPath) {
    do {
        try FileManager.default.createDirectory(atPath: inputBackPath,
                                    withIntermediateDirectories: true,
                                    attributes: nil)
        print("创建资源同步盘备份文件夹 \(inputBackPath)")
    }catch {
        print("创建资源同步盘备份文件夹 \(error)")
    }
}

guard FileManager.default.fileExists(atPath: outputAssetsFilePath) else {
    print(".xcassets 文件路径 \(outputAssetsFilePath) 不存在")
    exit(1)
}

guard outputAssetsFilePath.hasSuffix(".xcassets") else {
    print("输出文件不是一个 .xcassets  bundle 文件夹")
    exit(1)
}

/// MARK: diff 两个文件夹
// -r Recursively compare any subdirectories found.
// -q Output only whether files differ.
let reslut = ShellHelper.execute("diff","-r","-q","\(inputPath)","\(inputBackPath)")
let diffContent = reslut.output.split(separator: "\n")

let removePattern = "Only in\\s(\(inputBackPath).*):\\s(.*)"
let addPattern = "Only in\\s(\(inputPath).*):\\s(.*)"
let updatePattern = "Files\\s(.*)\\sand\\s(.*)\\sdiffer"

var addAssetFiles: [String] = []
var removeAssetFiles: [String] = []
var assetsGroupMap: [String: AssetGroup] = [:]

for content in diffContent {
    let line = String(content)
    if line.contains(".DS_Store") {
        continue
    }
    if let matchGroup = line.firstMatch(pattern: removePattern) {
        let removeAssetFilePath = matchGroup[1] + "/" + matchGroup[2]
        print("ready to remove: \(removeAssetFilePath)")
        removeAssetFiles.append(removeAssetFilePath)
        continue
    }

    if let matchGroup = line.firstMatch(pattern: addPattern) {
        let addAssetFilePath = matchGroup[1] + "/" + matchGroup[2]
        print("ready to add: \(addAssetFilePath)")
        addAssetFiles.append(addAssetFilePath)
        continue
    }

    if let matchGroup = line.firstMatch(pattern: updatePattern) {
        let addAssetFilePath = matchGroup[1]
        print("ready to update: \(addAssetFilePath)")
        addAssetFiles.append(addAssetFilePath)
        continue
    }
}

for removeAssetPath in removeAssetFiles {
    guard FileManager.default.fileExists(atPath: removeAssetPath) else {
        continue
    }
    try FileManager.default.removeItem(atPath: removeAssetPath)
    let outPutAssetPath = removeAssetPath.replacingOccurrences(of: inputBackPath, with: outputAssetsFilePath)
    if outPutAssetPath.isDirectory {
        do {
            print("\(outPutAssetPath) removed")
            try FileManager.default.removeItem(atPath: outPutAssetPath)
        } catch {
            print(error.localizedDescription)
        }
    } else {
        if Asset.isAsset(filePath: removeAssetPath) {
            let groupPath = URL(fileURLWithPath: outPutAssetPath)
                .deletingLastPathComponent()
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
            let asset = Asset(filePath: removeAssetPath)
            let assetGroup = AssetGroup(name: asset.groupName, groupPath: groupPath)
            print("\(assetGroup.imagesetDirectory) removed")
            assetGroup.remove()
        }
    }
}


func makeAssetGroup(filePath: String) {
    let outPutAssetPath = filePath.replacingOccurrences(of: inputPath, with: outputAssetsFilePath)
    if filePath.isDirectory {
        do {
            print("\(outPutAssetPath) created")
            try FileManager.default.createDirectory(atPath: outPutAssetPath, withIntermediateDirectories: true, attributes: nil)
            let contents = try FileManager.default.contentsOfDirectory(atPath: filePath)
            for content in contents {
                makeAssetGroup(filePath: filePath + "/" + content)
            }
        } catch {
            print(error.localizedDescription)
        }
    } else {
        if Asset.isAsset(filePath: filePath) {
            let groupPath = URL(fileURLWithPath: outPutAssetPath)
                .deletingLastPathComponent()
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
            let asset = Asset(filePath: filePath)
            guard let assetGroup = assetsGroupMap[asset.groupName] else {
                let assetGroup = AssetGroup(name: asset.groupName, groupPath: groupPath)
                assetsGroupMap[asset.groupName] = assetGroup
                assetGroup.assets.append(asset)
                return
            }
            assetGroup.assets.append(asset)
        }
    }
}

for orginAssetPath in addAssetFiles {
    makeAssetGroup(filePath: orginAssetPath)
}

for assetGroup in assetsGroupMap.values {
    let imagesetDirectory = assetGroup.imagesetDirectory
    do {
        print("\(imagesetDirectory) created")
        try FileManager.default.createDirectory(atPath: imagesetDirectory, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print(error.localizedDescription)
    }
    for asset in assetGroup.assets {
        print("copy \(asset.filePath) to \(imagesetDirectory)")
        ShellHelper.execute("cp","-r","\(asset.filePath)","\(assetGroup.imagesetDirectory)")
    }
    let imagesetInfoFilePath = assetGroup.imagesetInfoFilePath
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: assetGroup.info, options: .prettyPrinted)
        print("assetGroup.info: \(assetGroup.info)")
        try jsonData.write(to: URL(fileURLWithPath: imagesetInfoFilePath))
    } catch {
        print(error.localizedDescription)
    }

}

ShellHelper.execute("pwd")
ShellHelper.execute("cp","-r","\(inputPath)/","\(inputBackPath)")






