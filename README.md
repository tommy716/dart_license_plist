# DartLicensePlist

[![Pub Package](https://img.shields.io/pub/v/dart_license_plist.svg)](https://pub.dev/packages/dart_license_plist)
[![GitHub Issues](https://img.shields.io/github/issues/nomunomu0504/dart_license_plist.svg)](https://github.com/nomunomu0504/dart_license_plist/issues)
[![GitHub Forks](https://img.shields.io/github/forks/nomunomu0504/dart_license_plist.svg)](https://github.com/nomunomu0504/dart_license_plist/network)
[![GitHub Stars](https://img.shields.io/github/stars/nomunomu0504/dart_license_plist.svg)](https://github.com/nomunomu0504/dart_license_plist/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nomunomu0504/dart_license_plist/main/LICENSE)

`DartLicensePlist` is a command-line tool to generate a license file for the Dart programming language.

# Getting Started

install dart_license_plist.

```
$ dart pub global activate dart_license_plist
Resolving dependencies...
...
Downloading dart_license_plist <latest_version>...
Building package executables...
Built dart_license_plist:dart_license_plist.
Activated dart_license_plist <latest_version>.
```

# Usage

## For iOS
in ios, dart_license_plist execute using Settings.bundle in your project.

Should make Settings.bundle if not exists in `<project_root>/ios/Runner` folder.

On Menu on Xcode  
__File__ -> __New__ -> __File...__ -> __Settings.bundle__ -> __Create__ as `<project_root>/ios/Runner/Settings.bundle`

`*. lproj` folder not using in dart_license_plist, can delete if you not using.


## For platform except ios
Processing...

## For OSS used in native

dart_license_plist is only support dart's OSS, native needs to use another tool for native ios.

The recommendation is [LicensePlist](https://github.com/mono0926/LicensePlist).  
It also supports CocoaPods, Carthage and Manual(Git SubModule, direct sources and so on).