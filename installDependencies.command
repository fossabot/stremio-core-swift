#!/bin/bash

cargo install cargo-lipo
rustup toolchain install nightly
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios
