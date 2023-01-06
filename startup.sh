#!/usr/bin/env bash
 
function check_dependencies(){
    DEPS=("protoc" "protoc-gen-grpc-web" "npm" "npx" "python3" "node")
    echo "[*] Checking dependencies...";
 
    for dep in ${DEPS[@]}; do 
        if ! command -v $dep &> /dev/null
        then
            echo "[!]ERR: Dependency $dep could not be found. Please install."
            exit 1
        fi
    done
} 

function install_envoy(){
    echo "[*] Installing envoy"

    curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
    
    echo a077cb587a1b622e03aa4bf2f3689de14658a9497a9af2c427bba5f4cc3c4723 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check \
    
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/getenvoy.list \
    
    apt-get update && apt-get install -y getenvoy-envoy
}

function compile_protodef(){
    PROTODEF=helloworld.proto
    COMPILED_PROTO=helloworld_pb.js
 
    if test -f "$PROTODEF" && ! test -f "$COMPILED_PROTO"; then
        echo "[*] Compiling protobuf definition"
        protoc -I=. helloworld.proto \
        --js_out=import_style=commonjs:. \
        --grpc-web_out=import_style=commonjs,mode=grpcwebtext:.
    elif ! test -f "$PROTODEF"; then 
        echo "helloworld.proto not found! Are you in the right directory?"
        exit 1
    fi   
}
 
function compile_js(){
    WEBPACK_OUTPUT="./dist/main.js"
    if ! test -f "$WEBPACK_OUTPUT"; then
        echo "[*] Compiling webpack..."
        npm install 
        npx webpack client.js
    fi   
 
}
 
function run(){
    # echo "[*] Running Node server..."
    node server.js &
    BG_PID1=$!
 
    # echo "[*] Running Envoy proxy..."
    # docker run -v "$(pwd)"/envoy.yaml:/etc/envoy/envoy.yaml:ro -p 8080:8080 -p 9901:9901 envoyproxy/envoy:v1.22.0 &
    envoy -c envoy.yaml &
    BG_PID2=$!
 
    # echo "[*] Running Python web server..."
    python3 -m http.server 8081 & 
    BG_PID3=$!
 
    function killgroup(){ 
        kill -9 $BG_PID1
        kill -9 $BG_PID2
        kill -9 $BG_PID3
    }
 
    trap killgroup SIGINT
    wait
 
}
 
function main(){ 
    check_dependencies
    install_envoy
    compile_protodef
    compile_js
    run 
}
 
main