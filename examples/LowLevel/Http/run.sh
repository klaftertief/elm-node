elm make examples/LowLevel/Http/Main.elm --output=examples/LowLevel/Http/main.js
echo "Elm.worker(Elm.Main);" >> examples/LowLevel/Http/main.js
node examples/LowLevel/Http/main.js --port 8080
