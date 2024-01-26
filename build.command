#!/bin/bash

cargo lipo --release --targets aarch64-apple-ios
install_name_tool -id @rpath/libstremio_core_apple.dylib target/aarch64-apple-ios/release/libstremio_core_apple.dylib 