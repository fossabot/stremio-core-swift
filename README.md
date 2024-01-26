# stremio-core-apple

## This is stremio-core wrapper for apple devices. I used kotlin wrapper to port it to Apple ecosystem. My rust knowledge is amateur level so I may used bad approaches. 

# Setup

### Installing dependencies. You need to install rust on your macOS machine

```
./installDependencies.command 
```

### Build Bridge. It will create interface between Swift -> C -> Rust. Use this command when you make changes to C exports or in proto files

```
./installDependencies.command 
```

### Compile rust code to library file. 
```
./build.command 
```

Finally copy bridge folder to xcode and include wrapper.hpp in Objective-c bridging header. Finally copy library file to in target to xcode project.