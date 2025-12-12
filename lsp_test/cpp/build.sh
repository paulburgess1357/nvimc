#!/bin/bash

mkdir -p build
cd build
cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
make

# Copy compile_commands.json to project root for clangd
cp compile_commands.json ..
