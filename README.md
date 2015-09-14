# Introduction

The iOS Extension Crosswalk project implements the iOS Crosswalk APIs on top of the Crosswalk app runtime and its extension framework.

This repository is going to hold all the officially published Crosswalk iOS extensions, as well as the extension demos and samples.

# Extensions

[Cordova](extensions/Cordova)

[Presentation](extensions/Presentation)

# Quickstart

For hybrid developers, the easiest way to integrate Crosswalk extensions is using CocoaPods. You need to make sure you've already installed the CocoaPods on your computer. For the installation and usage of CocoaPods, please refer to: https://cocoapods.org/.

Basically the only thing you need to do is to create a `Podfile` in your project directory, and add a line of pod dependency which you need to use:

```bash
pod 'crosswalk-extension-cordova', '~> 1.0'
```

And in your app's manifest.json, add a line in `xwalk_extensions` to load the extension:

```json
'xwalk_extensions': [
  'xwalk.cordova'
],
```

Please refer to the instruction of each extension for more details.

# Development

* Clone the repo with command:

```bash
git clone https://github.com/crosswalk-project/ios-extensions-crosswalk.git
```

* Initialize the repo with command:

```bash
cd ios-extensions-crosswalk
git submodule update --init --recursive
```

* Install the pods for extension development with command:

```bash
pod install
```

* Open the `iOSExtension.xcworkspace`, build the extension targets.

# Demos

There are several demo applications to illustrate the usage of each extension, please refer to the directory [demos](demos) for more details.

# License

This project is available under the BSD license. See the [LICENSE](LICENSE) file for more info.

