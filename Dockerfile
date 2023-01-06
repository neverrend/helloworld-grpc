# sudo docker run -it --privileged -v /var/run/docker.sock:/var/run/docker.sock --entrypoint bash -p 8081:8081 helloworld:latest
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
                                        lsb-release 
                                        
# Move helloworld over
COPY . /helloworld
WORKDIR /helloworld

