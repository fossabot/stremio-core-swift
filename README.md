# Stremio-core-apple

This is stremio-core wrapper for apple devices. I used kotlin wrapper to port it to Apple ecosystem. My rust knowledge is amateur level so I may used bad approaches.

## Installing on a local machine

Install rust on your macOS machine:

```zsh
./installDependencies.command
```

Build Bridge. It will create interface between Swift -> C -> Rust. Use this command when you make changes to C exports or in proto files:

```zsh
./buildBridge.command
```

Compile rust code to library file.

```zsh
./build.command
```

Finally copy bridge folder to xcode and include it in your Objective-c bridging header, then add compiled library file to your xcode project.
