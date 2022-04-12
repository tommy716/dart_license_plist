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
**File** -> **New** -> **File...** -> **Settings.bundle** -> **Create** as `<project_root>/ios/Runner/Settings.bundle`

`*. lproj` folder not using in dart_license_plist, can delete if you not using.

## For platform except ios

Processing...

## For OSS used in native

dart_license_plist is only support dart's OSS, native needs to use another tool for native ios.

The recommendation is [LicensePlist](https://github.com/mono0926/LicensePlist).  
It also supports CocoaPods, Carthage and Manual(Git SubModule, direct sources and so on).

# Options

## `--custom-license-yaml`

Can use custom license data using `--custom-license-yaml` argument if the package license can not get.

The data of parsed custom-license-yaml takes priority over fetched license data from pub.dev and github.com.

### Yaml File Format

```
packages:
  <custom_license_package_name>:
    license: |
      <custom_license_text>
```

### Yaml File Sample

```
packages:
  package_name_1:
    license: |
      The MIT License

      Copyright (c) 2022 Hiroki Nomura.
      All rights reserved.

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in
      all copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.
  package_name_2:
    license: |
      The MIT License

      Copyright (c) 2022 Hiroki Nomura.
      All rights reserved.

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in
      all copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.
```
