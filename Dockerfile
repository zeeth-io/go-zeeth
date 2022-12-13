# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.18-alpine as builder

RUN apk add --no-cache gcc musl-dev linux-headers git

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /go-ethereum/
COPY go.sum /go-ethereum/
RUN cd /go-ethereum && go mod download

ADD . /go-ethereum
RUN cd /go-ethereum && go run build/ci.go install -static ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

ADD ./genesis.json ./genesis.json
ARG password=""
ARG privatekey=""
RUN echo $password > ~/.accountpassword
RUN echo $privatekey > ~/.privatekey

RUN geth init genesis.json
RUN geth account import --password ~/.accountpassword  ~/.privatekey

ENV address=""
ENV bootnodeId=""
ENV bootnodeIp="127.0.0.1"
ENV p2port=30303


EXPOSE 8545 8546
#ENTRYPOINT ["geth"]
#CMD exec geth --bootnodes "enode://$bootnodeId@$bootnodeIp:30301" --networkid="500" --verbosity=4 --rpc --rpcaddr "0.0.0.0" --rpcapi "eth,web3,personal,net,miner,admin,debug,db" --rpccorsdomain "*" --syncmode=full --etherbase $address
CMD exec geth  --bootnodes "enode://$bootnodeId@$bootnodeIp:30301" --networkid="90009" --port $p2port --verbosity=4  --http --http.addr "0.0.0.0" --http.api "eth,web3,personal,net,miner,admin,debug,db,clique" --http.corsdomain "*" --syncmode=full --miner.etherbase $address --mine --allow-insecure-unlock --unlock $address --password ~/.accountpassword --miner.gasprice "0"
  

# Add some metadata labels to help programatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
