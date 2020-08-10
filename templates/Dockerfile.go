FROM golang:alpine as builder
# Below ENV should be turned on when it is not possible to access google
# ENV GO111MODULE=on
# ENV GOPROXY=https://goproxy.io
RUN mkdir /build
ADD . /build/
WORKDIR /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app1 .
FROM scratch
COPY --from=builder /build/app1 /app/
# Config file "app1.cfg" should be copied to a seperate directory
# if Kubernetes config map needs to be used for configuration - mounted at the seperate directory
COPY --from=builder /build/app1.cfg /config/app1.cfg
WORKDIR /app
CMD ["./app1", "-f", "/config/app1.cfg"]
