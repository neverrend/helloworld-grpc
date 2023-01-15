# sudo docker run -it --rm  --entrypoint bash -p 8081:8081 -p 8080:8080 -p 9229:9229 helloworld:latest
FROM debian:latest

# Get some basic packages needed to do various things
RUN apt-get update && apt-get install -y nodejs \
                                        git \
                                        protobuf-compiler \
                                        curl \
                                        python3 \
                                        npm \
                                        ca-certificates \
                                        gnupg \
                                        lsb-release \
                                        debian-keyring \
                                        debian-archive-keyring \
                                        apt-transport-https
                                        
# Move helloworld over
COPY . /helloworld
WORKDIR /helloworld

RUN curl -L https://github.com/grpc/grpc-web/releases/download/1.4.2/protoc-gen-grpc-web-1.4.2-linux-x86_64 -o /usr/bin/protoc-gen-grpc-web \
    && chmod +x /usr/bin/protoc-gen-grpc-web