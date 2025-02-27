# Stremio-core-swift
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FAremixdj%2Fstremio-core-swift.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FAremixdj%2Fstremio-core-swift?ref=badge_shield)


`stremio-core-swift` is a wrapper for Apple operating systems, based on `stremio-core-kotlin`. Any changes that are not specific to Apple should be contributed to `stremio-core-kotlin`.

## Adding as an SPM Package

To integrate `stremio-core-swift` into your project, simply add it as a Swift Package Manager (SPM) package. It will automatically handle everything for you:

- Protobuf will be generated at Xcode compile time.
- The compiled Rust binary will be fetched from the releases.

## Alternatively, complie Rust Binary on Your Mac

To compile the Rust binary on your macOS machine, follow these steps:

1. **Install Apple Rust Dependencies:**

   Run the following command to install the necessary dependencies:

   ```zsh
   Support/installDependencies.command
   ```

2. **Compile rust code:**
   ```zsh
   make all
   ```


3. **Define the XCFramework in `Package.swift`:**

   Uncomment the local binary target in the Package.swift file:

   ```swift
   .binaryTarget(name: "XCFramework", path: ".build/StremioCore.xcframework")
   //.binaryTarget(name: "XCFramework", url: url, checksum: sha256)
   ```

4. **Add the Local Package in Xcode:**

   Finally, add the package as a local package in Xcode.


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FAremixdj%2Fstremio-core-swift.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FAremixdj%2Fstremio-core-swift?ref=badge_large)