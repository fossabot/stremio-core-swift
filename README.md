# Stremio-core-apple

This is stremio-core wrapper for apple devices. I used kotlin wrapper to port it to Apple ecosystem. My rust knowledge is amateur level so I may used bad approaches.

## Installing on a local machine

Install rust on your macOS machine:

```zsh
./installDependencies.command
```

Make package for xcode.

```zsh
make all
```

Package folder will be generated in build folder. It will contain protobuf files for swift and compiled binary for supported apple platforms
