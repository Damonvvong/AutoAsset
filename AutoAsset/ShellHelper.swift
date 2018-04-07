//
//  ShellHelper.swift
//  AutoAsset
//
//  Created by damonwong on 2018/4/7.
//  Copyright © 2018年 damonwong. All rights reserved.
//

import Foundation

class ShellHelper {
    @discardableResult
    static func execute(_ args: String...) -> (status:Int32, output:String) {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: .utf8)!
        return (status: process.terminationStatus, output: output)
    }
}
