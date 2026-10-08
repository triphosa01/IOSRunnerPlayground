# iOS Runner Playground

A small native SwiftUI app for experimenting with iOS development and GitHub-hosted macOS runners.

## Build locally on a Mac

Install Xcode and XcodeGen, then from this folder run:

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project IOSRunnerPlayground.xcodeproj \
  -scheme IOSRunnerPlayground \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Open `IOSRunnerPlayground.xcodeproj` in Xcode to run the app in a simulator.

## Build with GitHub Actions

The `iOS Build` workflow runs on GitHub's `macos-15` hosted runner for pushes, pull requests, and manual runs. It generates the Xcode project from `project.yml` and builds the app for the iOS Simulator; no signing certificate or Apple Developer account is needed for this build.

To try the hosted runner, create a GitHub repository for this folder, push the project, and check the **Actions** tab.
