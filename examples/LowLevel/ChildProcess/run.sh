#!/bin/bash
elm make examples/LowLevel/ChildProcess/Main.elm --output=examples/LowLevel/ChildProcess/main.js
echo "Elm.worker(Elm.Main);" >> examples/LowLevel/ChildProcess/main.js
echo "What does elm make say?"
node examples/LowLevel/ChildProcess/main.js
