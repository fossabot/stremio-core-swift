#!/bin/bash

# Set the input directory where your .proto files are located
PROTO_DIR="src/main/proto"

# Set the output directory for the generated Objective-C files
OUTPUT_DIR="bridge"

# Find all .proto files in the input directory
PROTO_FILES=$(find "$PROTO_DIR" -name "*.proto")

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate Objective-C files from each .proto file
for PROTO_FILE in $PROTO_FILES; do
  # Extract the filename without extension
  FILENAME=$(basename -- "$PROTO_FILE")
  FILENAME_NOEXT="${FILENAME%.*}"

  # Generate Objective-C files using protoc
  protoc \
    --swift_out="$OUTPUT_DIR" \
    --proto_path="$PROTO_DIR" \
    "$PROTO_FILE"

  echo "Generated Swift files for $FILENAME_NOEXT"
done

cbindgen -o bridge/wrapper.hpp  
