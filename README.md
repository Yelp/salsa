## What is Salsa?
Salsa is an open source library that renders iOS views and exports them into a Sketch file. We built Salsa to help bridge the gap between design and engineering in an effort to create a single source of truth for visual styling of UI.

## How it works
Running Salsa inside of an iOS simulator will output two things into a specified directory: a .salsa file and an images folder. You can then pass these two inputs into the salsa command line tool to compile them into a .sketch file.

### Why two steps?
Certain macOS-only APIs need to be used to encode text for .sketch files. Having two steps allows us to define our own intermediate file format that’s easier to work with than the full sketch file format. This means we can leverage this file format in the future if we want to expand this tool for other platforms.

# Installing Salsa
```ruby
pod 'Salsa'
```

```bash
brew tap yelp/salsa
brew install salsa
```

# Using Salsa
```swift
import Salsa
```
##### Converting a view to a [Sketch Group](https://www.sketchapp.com/docs/grouping/groups/)
```swift
// Configure the export directory
SalsaConfig.exportDirectory = "/some_directory"

// Convert a view into a group
let myGroup = myView.makeSketchGroup()
```
##### Putting a group into a sketch document and exporting to a salsa file
```swift
// Create a page containing the generated group, and insert it into a Document
let document = Document(pages: [Page(layers: [myGroup])])

// Export the document to disk
try? document.export(fileName: "my_file")
```

##### Converting a salsa file to a sketch file
In your terminal of choice run the following:
```bash
$ salsa -f /some_directory/my_file.salsa -e /some_directory/my_file.sketch
```

## Creating a Sketch file documenting your standard UI elements
We provide some helpers to help you document your elements out of the box. You organize examples of your views into an [Artboard](https://www.sketchapp.com/docs/grouping/artboards/) by conforming your view class to `ArboardRepresentable`.
```swift
extension View1: ArtboardRepresentable {
  static func artboardElements() -> [[ArtboardElement]] {
    ...
  }
}
```
If you would like to also create [Symbols](https://sketchapp.com/docs/symbols/) of your views to go along with the generated Artboards you can instead conform your views to `SymbolRepresentable`.

```swift
extension View2: SymbolRepresentable {
  static func artboardElements() -> [[ArtboardElement]] {
    ...
  }
}
```
Create your Artboards and Symbols from these `ArboardRepresentable`  and `SymbolRepresentable` views
```swift
// Configure the export directory
SalsaConfig.exportDirectory = "/some_directory"

// Generate the artboards and symbols
let artboardsAndSymbols = makeArtboardsAndSymbols(from: [[View1.self], [View2.self]])

// Put the artboards and symbols onto their own dedicated pages
let artboardPage = Page(name: "Artboards", layers: artboardsAndSymbols.artboards)
let symbolPage = Page(name: "Symbols", layers: artboardsAndSymbols.symbols)

// Create a document with the generated pages and export it
let document = Document(pages: [artboardPage, symbolPage])
try? document.export(fileName: "my_file")
```

## Example Project
Check out the Example project to see how Sasla can be used in production. The Example app uses a test target to generate Sketch files without manually launching Xcode.  

To generate a Sketch file for the Example project run the following after cloning the repo:
```bash
cd Example
pod install
./generate_sketch
```
This should create a new file called `ExampleSketch.sketch` inside the project directory

Open up [`generate_sketch`](https://github.com/Yelp/salsa/blob/master/Example/generate_sketch) with a text editor to see how this is done.
