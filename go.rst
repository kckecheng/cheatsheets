.. contents:: Golang Tips

Golang Tips
=============

Module
-------

Go native dependency management mechanism. Refer to https://github.com/golang/go/wiki/Modules for details.

Enable Go Module
~~~~~~~~~~~~~~~~~

::

  # old style
  # export GO111MODULE=auto
  export GO111MODULE=on
  # new style
  go env -w GO111MODULE=on

Go Module Proxy
~~~~~~~~~~~~~~~~

**go get** will fetch packages from their sources directly, such as from github.com, googlesource, etc. Such operations are expensive, and sometimes are even not possible (e.g., golang.org cannot be accessed from within China without a proxy). By enabling the go module feature and setting GOPROXY, packages can be retrieved more fast from a CDN like mirror.

  ::

    # old style
    export GO111MODULE=on
    export GOPROXY=https://goproxy.io
    # new style
    # go env -w GO111MODULE=on
    # go env -w GOPROXY=https://goproxy.io
    # go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
    go get -u <package>

**Tips:** the same problem will be hit when build docker images for go apps. This can be worked around by setting ENV values in a dockerfile as below:

::

  FROM ......
  ENV GO111MODULE=on
  ENV GOPROXY=https://goproxy.io
  ......

Reference:

- `A Global Proxy for Go Modules <https://goproxy.io/>`_

Version Selection
~~~~~~~~~~~~~~~~~~

By default, a new import will fetch the latest version of a package. However, there are use cases that specified versions of packages should be used.

::

  # within go.mod
  require github.com/coreos/go-systemd v22.1.0
  # then run command "go mod tidy"

The Replace Directive
~~~~~~~~~~~~~~~~~~~~~~

**replace** directive allows to replace module/package dependencies with local copies or alternative repositories. It can be added before/after the require directive in go.mod

::

  replace github.com/user1/pkg1 => /local/dir/pkg1
  replace golang.org/google/pkg1 => github.com/google/pkg1
  # specify the exact version
  replace github.com/coreos/go-systemd => github.com/coreos/go-systemd v22.1.0
  replace github.com/coreos/go-systemd v22.0.0 => github.com/coreos/go-systemd v22.1.0

Edit go.mod from CLI
~~~~~~~~~~~~~~~~~~~~~

::

  go mod edit -require github.com/user1/pkg2
  go mod edit -require github.com/user1/pkg2@version1
  go mod edit -replace github.com/user1/pkg1=/local/dir/pkg1
  go mod edit -replace github.com/user1/pkg1@version1=/local/dir/pkg1@version2

Cross Plafom Build
-------------------

::

  #Build for Window on Linux or vice versa
  # CGO_ENABLED=0 can be specified to force static linking
  GOOS=windows GOARCH=amd64 go build -v
  GOOS=linux GOARCH=amd64 go build -v

go test
--------

- Pass argument within test through "flag"

  * Declare the arguments normally within the test code without calling flag.Parse():

     ::

        package hello

        import (
           "flag"
           "testing"
        )

        var name = flag.String("name", "", "Name to say hi to")

        func TestGenerateGoPackage(t \*testing.T) {
           t.Log(\*pkgdir)
        }

  *  Pass arguments as below:

     ::

        go test -v hello.go -args -name "John Smith"

- Coverage

  ::

    go test -v -cover ./...

- Run a single test

  ::

    go test -v -run TestXXX ./...

- Disable test caching

  ::

    go test -v -cover -count=1 ./...

- Solutions for "flag provided but not defined"

  * Known issue: https://github.com/golang/go/issues/31859
  * Do not call "flag.Prase()" in any "init()"

Debug with delve
-----------------

- Basics

  `Github Reference <https://github.com/go-delve/delve>`_


  ::

    # if dlv is executed from the directory where main.go is defined
    dlv debug
    # if dlv is run from other dirs
    dlv debug <package name>
    # pass parameters
    dlv debug -- -arg1 value1

- Pass argument with dlv debug

  ::

    dlv debug <app>.go -- <param1> <param2> ...

- Debug test

  ::

    # dlv test <package or ./...> -- [-test.v] [-test.cover] [-test.run TestXXX]
    # Select a single test torun
    dlv test ./... -- -test.run TestListResources

Document
---------

- Offline document

  * Install godoc

    ::

      # Turn off Go module if it is enabled
      # GO111MODULE=off go get -v golang.org/x/tools/cmd/godoc
      go get -v golang.org/x/tools/cmd/godoc

  * Usage

    ::

      godoc -http=0.0.0.0:8080

- Docs for builtin types and functions

  ::

    go doc builtin
    go doc builtin.<symbol>

Import
-------

- Alias

  ::

    import <alias name> <package>

- Dot import: imports the package into the same namespace as the current package

  ::

    import . "math"
    fmt.Println(Pi)

- Blank import: init the package and stop compiling error

  ::

    import _ <package name>

- Silence complaints about the unused imports

  * Blank import: this is used mainly for package initialization, the init method will be executed

    ::

      import _ <pacakge name>

  * Refer to some symbols with blank identifier: mainly used during debug

    ::

      import <pacakge name>
      var _ = <pacakge name>.<any symbol>

Package init
-------------

- init function

  Each source file can define an **init** function to set up corresponding requirements, and multiple init functions can exist within the same package. While such a package is imported, all init functions will be executed based on source file names.


  **init function signature**

  ::

    func init() {
      <code>
    }

- package initialization order

  - const will be initialized at first
  - var will be initialized then
  - all init functions will be called

Multiple expressions for switch case
--------------------------------------

::

  switch letter {
  case "a", "b", "c":
    fmt.Println("case 1")
  default:
    fmt.Println("case 2")
  }

Triple dots/ellipsis
----------------------

- Variadic function

  ::

    func Sum(nums ...int) int {
      res := 0
      for _, n := range nums {
          res += n
      }
      return res
    }

- Arguments to variadic functions

  ::

    primes := []int{2, 3, 5, 7}
    Sum(primes...)

- Array literals

  ::

    names := [...]string{"a", "b", "c"}

- Special go commands

  ::

    # tests all packages in the current directory and its subdirectories
    go test ./...
    # download all dependent packages of a go module
    go get ./...

iota
------

- The iota keyword represents successive integer constants 0, 1, 2, ...
- It resets to 0 whenever the word const appears in the source code
- It increments after each const specification
- Each source code file reset the value from beginning

**Examples:**

- Basic usage: the below 2 x forms are identical

  ::

    //C0, C1, C2 will be 0, 1, 2
    const (
      C0 = iota
      C1 = iota
      C2 = iota
    )

    const (
      C0 = iota
      C1
      C2
    )

- Start from non-zero

  ::

    //C0, C1, C2 will be 1, 2, 3
    const (
      C0 = iota + 1
      C1
      C2
    )

- Skip values

  ::

    //C0, C1, C2 will be 0, 2, 4
    const (
      C0 = iota
      -
      C1
      -
      C2
    )

List packages
----------------

- List packages under the workspace

  ::

    cd <workspace dir>
    go list ./...

- List all packages including packages from the std library and external libraries from the workspace

  ::

    go list ...

- List standard packages

  ::

    go list std

List api of packages
----------------------

List the full API of a package:

::

  # Locate the package/module name
  go list ...
  # Show the API
  go tool api <package|module>
  # Show the document for an object of the package/module
  go doc <package>[.<object>]

Techs to build docker image
-----------------------------

The sample main.go as below is used for the show:

::

  package main

  import (
          "fmt"
          "time"
  )

  func main() {
          i := 0
          for {
                  i++
                  fmt.Printf("Hello World: %d\n", i)
                  time.Sleep(3 * time.Second)
          }
  }

- The straightforward build: the result docker image is over 350MB

  ::

    FROM golang:alpine
    RUN mkdir /app
    ADD . /app/
    WORKDIR /app
    RUN go build -o main .
    CMD ["./main"]

- Multistage build: the result docker image is about 8MB

  ::

    FROM golang:alpine as builder
    RUN mkdir /build
    ADD . /build/
    WORKDIR /build
    RUN go build -o main .

    FROM alpine
    COPY --from=builder /build/main /app/
    WORKDIR /app
    CMD ["./main"]

- Build from scratch: the result docker image is just about **2MB**

  ::

    FROM golang:alpine as builder
    RUN mkdir /build
    ADD . /build/
    WORKDIR /build
    RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o main .
    FROM scratch
    COPY --from=builder /build/main /app/
    WORKDIR /app
    CMD ["./main"]

gRPC
-----

- Generate codes under the same directory as the proto file

  ::

    protoc -I <import_path1 import_path2 ...> <path to proto file>/<xxx>.proto --go_opt=paths=source_relative --go_out=plugins=grpc:<path to proto file>


go-micro
---------

Use consul for go-micro
~~~~~~~~~~~~~~~~~~~~~~~~

Since go-micro v2, etcd is used as the default system discovery system based on `this blog post <https://micro.mu/blog/2019/10/04/deprecating-consul.html>`_. The code base has been restructured accordingly which impacts both go-micro and go-micro/v2. To keep use consul:

- go-micro v1:

  - Use protoc-gen-micro v1

    ::

      go get github.com/micro/protoc-gen-micro

  - Create plugins.go:

    ::

      pacakge main
      import _ "github.com/micro/go-plugins/registry/consul"

  - In the application:

    ::

      package main
      import "github.com/micro/go-micro"

- go-micro v2:

  - Use protoc-gen-micro v2

    ::

      go get github.com/micro/protoc-gen-micro/v2

  - Create plugins.go:

    ::

      package main
      import _ "github.com/micro/go-plugins/registry/consul/v2"

  - In the application:

    ::

      package main
      import "github.com/micro/go-micro/v2"

To run a go-micro based application with consul:

::

  go run main.go plugins.go --registry consul --registry_address 192.168.10.10:8500

Use micro runtime with non-default plugins
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If non-default plugins (such as consul, kafka, etc.) are used in a service implementation, micro runtime needs to know the changes. Below is an example:

1. A service is implemented by leveraging plugins consul and kafka. The plugins.go is defined as below:

   ::

     package main
     import (
       _ "github.com/micro/go-plugins/registry/consul/v2"
       _ "github.com/micro/go-plugins/broker/kafka/v2"
     )

#. Start micro runtime from CLI by loading the non-default plugins:

   ::

      micro --plugin registry/consul/v2 --plugin broker/kafka/v2 \
      --registry consul --registry_address localhost:8500 \
      --broker kafka --broker_address localhost:9092 cli

#. Start micro runtime from web by loading the non-default plugins:

   ::

      micro --plugin registry/consul/v2 --plugin broker/kafka/v2 \
      --registry consul --registry_address localhost:8500 \
      --broker kafka --broker_address localhost:9092 \
      web --address=0.0.0.0:8080

go-micro metadata
~~~~~~~~~~~~~~~~~~~

metadata can be used to pass data across requests with the help of context. Below is a simple example:

- Server side:

  - Method signatures for a server interface will always look as below:

    ::

       Foo(context.Context, *Request, *Response) error

  - To extract metadata passed through the request context, below code snip can be used when method signatures (Foo in this example) are implemented:

    ::

      import (
        "context"
        proto "hello/proto/hello"
        log "github.com/micro/go-micro/v2/logger"
        "github.com/micro/go-micro/v2/metadata"
        ...
      )
      ...

      type Hello struct{}

      func (h *Hello) Foo(ctx context, req *proto.Request, rsp *proto.Response) error {
        ...
        md, _ := metadata.FromContext(ctx)
        # md is map[string]string
        log.Infof("%+v", md)
        ...
      }

- Client side:

  ::

    ...
    client := proto.NewHelloService("go.micro.srv.hello", service.Client())
    # md is map[string]string
    md := metadata.Metadata{}
    md["Token"] = "abc123"
    ...
    ctx := metadata.NewContext(context.Background(), md)
    resp, err := client.Foo(ctx, &proto.Request{Name: "John"})
    ...

- micro api: when the service is consumed from micro api, metadata needs to be used as HTTP headers

  - Start micro api:

    ::

      micro api --enable_rpc

  - Consume the service: **pass metadata as HTTP headers**

    ::

      curl -H 'Token: abc123' -d 'service=go.micro.srv.hello' -d 'method=Hello.Foo' -d 'request={"name": "John"}' http://localhost:8080/rpc

  - Known issue: HTTP API cannot be used with "/[service]/[method]" due to a known issue, use "/rpc" instead

Type assert vs. type conversion
--------------------------------

- Type assert only works for interface

  ::

    // i implements an interface
    t := i.(T)
    t, ok := i.(T)

- Type conversion is used to convert between variable types

  ::

    a, b := 3, 10
    c := float32(a) / flat32(b)

- Type casting exists in go, but is rarely used - ignore this
- Type switch is only a special switch statement

  ::

    // "type" is literal, no other word can be used;
    // i.(type) will trigger errors if it is not used with the switch statement;
    switch v := i.(type) {
    case T:
      // some ops
    case S:
      // some ops
    default:
      // some ops
    }

Type alias vs. type definition
--------------------------------

- Type alias

  ::

    type T1 = T2

- Type definition

  ::

    type T1 T2

defer, panic and recover
--------------------------

- Order: refer to "go doc builtin.panic";
- Variables referred by deferred functions are determined at **compile time**:

  ::

    /*
      The output will be:
      Initial 10
      Change 20
      Defer 10 - 10 is determined at the compile time
    */
    func main() {
            a := 10
            fmt.Println("Initial", a)
            defer fmt.Println("Defer", a)
            a = 20
            fmt.Println("Change", 20)
    }

- Recover works only when it is called from **the same goroutine** which is panicking;
- Re-panic can be used to indicate the captured panic cannot be handled by the recover logics;
- Named return (naked return) must be used to return values from a panic:

  ::

    /*
        The output will be:
        foo: panic
        main received value: 0
        main received error: Assign value during recover

    */
    func main() {
            n, err := foo()
            fmt.Println("main received value:", n)
            fmt.Println("main received error:", err)
    }

    func foo() (retv int, rete error) {
            defer func() {
                    if err := recover(); err != nil {
                            fmt.Println(err)
                            // retv, rete will be return values once panic is captured
                            retv = 0
                            rete = errors.New("Assign value during recover")
                    }
            }()
            retv = 1
            panic("foo: panic")
            retv = 3
            rete = nil
            // return retv, rete
            return
    }

- Recover sample:

  ::

    /*
      The main function reach the last line "In main: end" since the panic has been recovered
    */
    func panicOut() {
            defer func() {
                    fmt.Println("In panicOut: defer")
                    if err := recover(); err != nil {
                            fmt.Println("In panicOut recover")
                            fmt.Println("In panicOut recover:", err)
                            // Re-panic if needed
                            // panic("Cannot handle the error")
                    }
            }()
            fmt.Println("In panicOut: start")
            panic("panic")
            fmt.Println("In panicOut: end")
    }

    func main() {
            fmt.Println("In main: start")
            panicOut()
            fmt.Println("In main: end")
    }

go-swagger
------------

Install swagger CLI
~~~~~~~~~~~~~~~~~~~~

::

  go get -u -v github.com/go-swagger/go-swagger/cmd/swagger
  swagger --help
