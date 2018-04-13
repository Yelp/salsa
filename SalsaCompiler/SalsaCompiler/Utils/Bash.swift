//
//  Bash.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 2/23/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import Foundation

/// Executes a bash command. Taken and modified from https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
func bash(command: String, arguments: [String], directory: String = "/") -> (returnCode: Int32, output: String) {
  func shell(launchPath: String, arguments: [String]) -> (returnCode: Int32, output: String) {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    task.currentDirectoryPath = directory

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    var output = String(data: data, encoding: String.Encoding.utf8)!
    if output.count > 0 {
      // remove newline character.
      let lastIndex = output.index(before: output.endIndex)
      output = String(output[output.startIndex ..< lastIndex])
    }
    task.waitUntilExit()
    return (returnCode: task.terminationStatus, output: output)
  }

  // First we find the path for the command we want by using which
  let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ]).output
  // Then execute that command
  return shell(launchPath: whichPathForCommand, arguments: arguments)
}


