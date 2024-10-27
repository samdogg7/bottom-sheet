Please keep in mind that Bottom Sheet is still in beta. Some documentation is missing, more modifiers coming soon!

# Bottom Sheet
A small and lightweight library that adds a bottom sheet that can be used with TabView to make it stay on top. And more!

![example-ezgif com-video-to-gif-converter-2](https://github.com/user-attachments/assets/a28b9c81-7a19-4873-8aef-9a5a4f67cd9d)


# Why?
The main idea behind BottomSheet is to allow you to add a sheet that can be displayed below the TabView rather than with the native .sheet, which will always be shown on top of all elements.
BottomSheet can be used to recreate the sheet from Apple Maps, Shortcuts and Apple Music.

# Requirements 
- iOS 18,
- Swift 6.0
- Xcode 16

# Installation

## Swift Package Manager

The preferred way of installing BottomSheet is via the Swift Package Manager.

Xcode 16 integrates with libSwiftPM to provide support for iOS, watchOS, and tvOS platforms.
In Xcode, open your project and navigate to File → Add Packages
Paste the repository URL (https://github.com/wojtek717/bottom-sheet) and click Next.
For Rules, select Up to Next Major Version.
Click Add Package.

# Usage

``` Swift
 Map { }
.bottomSheet(isPresented: $showCustomSheet) {
// Sheet content goes here
}
  .detents([.small, .medium, .large]) // configure sheet detents
  .dragIndicator(isVisible: true) // display drag indicator
```

# Modifiers
`.detents([Detent])`:
Sets the available detents for the enclosing sheet.

`.dragIndicator(isVisible: Bool, color: Color = .gray)`:
Sets the visibility of the drag indicator on top of a sheet and it's color.

`.sheetColor(_ color: Color)`:
Sets sheet's background color.
