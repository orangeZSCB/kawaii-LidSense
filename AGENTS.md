# Agent Instructions

- Public-facing documentation and comments should be written in English.
- Keep `LidSense.xcodeproj` committed. Do not ignore or remove the Xcode project.
- Do not commit `xcuserdata/`, `.DS_Store`, build outputs, signing certificates, or provisioning profiles.
- This app uses undocumented IOKit HID behavior. Avoid presenting it as a stable macOS API.
- App Sandbox is disabled because the app reads a low-level HID feature report. Do not re-enable it without testing sensor access.
- Keep dependencies minimal. Prefer native SwiftUI and Apple frameworks.
- Before publishing changes, build the `LidSense` target in Xcode or with `xcodebuild` when possible.
