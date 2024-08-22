LIBRARY_NAME := libstremio_core_swift
FRAMEWORK_NAME := StremioCore
.PHONY: all

all: macos ios iossim tvossim tvos visionossim package

macos:
	@cargo +nightly build -Z build-std --release --lib --target aarch64-apple-ios-macabi
	@cargo +nightly build -Z build-std --release --lib --target x86_64-apple-ios-macabi
	@$(RM) -rf target/universal/$(LIBRARY_NAME)-macabi.a
	@mkdir -p target/universal/
	@lipo -create -output target/universal/$(LIBRARY_NAME)-macabi.a \
		target/aarch64-apple-ios-macabi/release/$(LIBRARY_NAME).a \
		target/x86_64-apple-ios-macabi/release/$(LIBRARY_NAME).a

ios:
	@cargo build --release --lib --target aarch64-apple-ios
	@$(RM) -rf target/universal/$(LIBRARY_NAME)-ios.a
	@mkdir -p target/universal/
	@cp target/aarch64-apple-ios/release/$(LIBRARY_NAME).a target/universal/$(LIBRARY_NAME)-ios.a

iossim:
	@cargo build --release --lib --target aarch64-apple-ios-sim
	@cargo build --release --lib --target x86_64-apple-ios
	@$(RM) -rf target/universal/$(LIBRARY_NAME)-ios-sim.a
	@mkdir -p target/universal/
	@lipo -create -output target/universal/$(LIBRARY_NAME)-ios-sim.a \
		target/aarch64-apple-ios-sim/release/$(LIBRARY_NAME).a \
		target/x86_64-apple-ios/release/$(LIBRARY_NAME).a

tvossim:
	@cargo build -Z build-std --release --lib --target aarch64-apple-tvos-sim
	@$(RM) -rf target/universal/$(LIBRARY_NAME)-tvos-sim.a
	@mkdir -p target/universal/
	@cp target/aarch64-apple-tvos-sim/release/$(LIBRARY_NAME).a target/universal/$(LIBRARY_NAME)-tvos-sim.a

tvos:
	@cargo build -Z build-std --release --lib --target aarch64-apple-tvos
	@$(RM) -rf target/universal/$(LIBRARY_NAME)-tvos.a
	@mkdir -p target/universal/
	@cp target/aarch64-apple-tvos/release/$(LIBRARY_NAME).a target/universal/$(LIBRARY_NAME)-tvos.a

visionossim:
	@cargo +nightly build -Z build-std --release --lib --target aarch64-apple-visionos-sim
	@$(RM) -rf target/universal/$(LIBRARY_NAME)-visionos-sim.a
	@mkdir -p target/universal/
	@cp target/aarch64-apple-visionos-sim/release/$(LIBRARY_NAME).a target/universal/$(LIBRARY_NAME)-visionos-sim.a

framework:
	@mkdir -p .build/
	@$(RM) -rf .build/$(FRAMEWORK_NAME).xcframework
	@xcodebuild -create-xcframework \
		-library target/universal/$(LIBRARY_NAME)-ios.a \
		-library target/universal/$(LIBRARY_NAME)-ios-sim.a \
		-library target/universal/$(LIBRARY_NAME)-macabi.a \
		-library target/universal/$(LIBRARY_NAME)-visionos-sim.a \
		-library target/universal/$(LIBRARY_NAME)-tvos-sim.a \
		-library target/universal/$(LIBRARY_NAME)-tvos.a \
		-output .build/$(FRAMEWORK_NAME).xcframework

package: framework
	@$(RM) -rf Sources/StremioCore/stremio
	@./buildBridge.command
