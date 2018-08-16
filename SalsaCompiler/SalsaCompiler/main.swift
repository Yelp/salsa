import Cocoa

let usage = """
Usage: \((CommandLine.arguments[0] as NSString).lastPathComponent) -f input_file -e export_file [-i images_directory] [-h]
\t-f input_file: Path to the .salsa file from the current directory
\t-e export_file: Path and name of the exported sketch file
\t-i images_directory: Directory containing the image assets referenced in the .salsa file. Defaults to input_file_directory/images
\t-h: Prints this help message
"""

// Check for help flags before doing anything else
if CommandLine.arguments.index(of: "-h") != nil || CommandLine.arguments.index(of: "--help") != nil {
  print(usage)
  exit(0)
}

/// Finds an argument given its flag
func argument(forOption option: String) -> String? {
  guard let optionIndex = CommandLine.arguments.index(of: option), optionIndex + 1 < CommandLine.arguments.count else {
    return nil
  }
  return CommandLine.arguments[optionIndex + 1]
}

// Parse the input file param
guard let filePathString = argument(forOption: "-f") else {
  fatalError("No input file.\n\(usage)")
}
let filePath = URL(fileURLWithPath: filePathString)

// Parse the images directory param
let imagesDirectory: URL = {
  if let pathString = argument(forOption: "-i") {
    return URL(fileURLWithPath: pathString)
  } else {
    return filePath.deletingLastPathComponent().appendingPathComponent("/images/")
  }
}()

// Parse the export file param
let exportFile: URL = {
  guard var pathString = argument(forOption: "-e") else {
    fatalError("No export file.\n\(usage)")
  }
  if !pathString.hasSuffix(".sketch") {
    pathString += ".sketch"
  }
  return URL(fileURLWithPath: pathString)
}()


// Find a name for the working directory
let workingDirectory: URL = {
  let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
  while true {
    let directory = tempDir.appendingPathComponent(UUID().uuidString, isDirectory: true)
    if !FileManager.default.fileExists(atPath: directory.path) {
      return directory
    }
  }
}()

func cleanupWorkingDirectory() {
  try? FileManager.default.removeItem(at: workingDirectory)
}

func exit(withMessage message: String) -> Never {
  cleanupWorkingDirectory()
  fatalError(message)
}

// Create the working directory
do {
  try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true, attributes: nil)
} catch {
  exit(withMessage: "Failed to create directory: \(workingDirectory.path)")
}

// Clone images into the working directory
do {
  try FileManager.default.copyItem(at: imagesDirectory, to: workingDirectory.appendingPathComponent("images", isDirectory: true))
} catch {
  exit(withMessage: "Failed to clone images directory: \(imagesDirectory.path)")
}

// Read in the input file
let json = parseJsonFile(at: filePath.path)
guard let document = Document(json: json) else {
  exit(withMessage: "Failed to parse \(filePath.lastPathComponent)")
}

// Create /pages/ directory
let pagesDirectory = workingDirectory.appendingPathComponent("pages", isDirectory: true)
do {
  try FileManager.default.createDirectory(at: pagesDirectory, withIntermediateDirectories: true, attributes: nil)
} catch {
  exit(withMessage: "Failed to create directory: \(pagesDirectory.path)")
}

// Configure identifiers for shared objects
IdentifierStore.configure(with: document)

// Convert pages to json and save them to disk
document.pages.enumerated().forEach { index, page in
  guard let pageID = IdentifierStore.identifier(forPageNamed: page.name) else { exit(withMessage: "Failed to create page \(index + 1)")  }
  do {
    let url = pagesDirectory.appendingPathComponent("\(pageID).json")
    guard let pageJsonString = page.simplified().toSketchJson().toJsonString() else { exit(withMessage: "Failed to parse page \(index + 1)") }
    try pageJsonString.write(to: url, atomically: false, encoding: String.Encoding.utf8)
  } catch {
    exit(withMessage: "Failed to save page \(index + 1)")
  }
}

// Create document.json
guard let documentJson = document.toSketchJson(pageIds: document.pages.reversed().compactMap { IdentifierStore.identifier(forPageNamed: $0.name) }).toJsonString() else {
  exit(withMessage: "Failed to convert document to json")
}

// Save document.json to disk
do {
  let url = workingDirectory.appendingPathComponent("document.json")
  try documentJson.write(to: url, atomically: false, encoding: String.Encoding.utf8)
} catch {
  exit(withMessage: "Failed to save document.json to disk")
}

// Create meta.json
guard let metaData = makeMetaData().toJsonString() else {
  exit(withMessage: "Failed to generate meta.json")
}

// Save meta.json to disk
do {
  let url = workingDirectory.appendingPathComponent("meta.json")
  try metaData.write(to: url, atomically: false, encoding: String.Encoding.utf8)
} catch {
  exit(withMessage: "Failed to save meta.json")
}

// Sketch requires that this file exists but it doesn't need to contain anything
// Its used to recover your position and state in the document on subsequent launches
do {
  let url = workingDirectory.appendingPathComponent("user.json")
  try [String: Any]().toJsonString()!.write(to: url, atomically: false, encoding: String.Encoding.utf8)
} catch {
  exit(withMessage: "Failed to save user.json")
}


let exportDirectory = exportFile.deletingLastPathComponent()
let exportFileName = exportFile.lastPathComponent

// Create the export directory if it doesn't exist
if !FileManager.default.fileExists(atPath: exportDirectory.path) {
  do {
    try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true, attributes: nil)
  } catch {
    exit(withMessage: "Failed to create directory: \(exportDirectory.path)")
  }
}

// Swift doesn't come with zipping utilities. Instead of adding one as a dependency we just use bash to zip our exported files into a sketch file
guard bash(command: "zip", arguments: ["-r", "\(exportDirectory.path)/\(exportFileName)", "./"], directory: workingDirectory.path).returnCode == 0 else {
  exit(withMessage: "Failed to create zipped .sketch file. Do you have zip installed?")
}

// Clean up our working directory
cleanupWorkingDirectory()

print("(☞ﾟヮﾟ)☞ Generated \(exportFile.path) ☜(ﾟヮﾟ☜)")

