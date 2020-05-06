.. contents:: Golang Tips

Golang Tips
=============

Pass argument through package flag in go test
-----------------------------------------------

1. Declare the arguments normally within the test code without calling flag.Parse():

   .. code-block:: go

      package hello

      import (
         "flag"
         "testing"
      )

      var name = flag.String("name", "", "Name to say hi to")

      func TestGenerateGoPackage(t \*testing.T) {
         t.Log(\*pkgdir)
      }

2. Pass arguments as below:

   .. code-block:: go

      go test -v hello.go -args -name "John Smith"

Pass argument with dlv debug
-----------------------------

::

  dlv debug <app>.go -- <param1> <param2> ...

Offline document
-------------------

golang ships with offline document. But **godoc** need to be used to access them.

- Install godoc

  ::

    go get -v golang.org/x/tools/cmd/godoc

- Usage

  ::

    godoc -http=0.0.0.0:8080

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

Silence complaints about the unused imports
--------------------------------------------

Complaints will be raised if a module is imported without usage. This are 2 x methods to supress this:

- Blank import: this is used mainly for package initialization, the init method will be executed

  ::

    import _ <pacakge name>

- Refer to some symbols with blank identifier: mainly used during debug

  ::

    import <pacakge name>
    var _ = <pacakge name>.<any symbol>

Specify proxy for go commands
------------------------------

**go get** will fetch packages from their sources directly, such as from github.com, googlesource, etc. Such operations are expensive, and sometimes are even not possible (e.g., golang.org cannot be accessed from within China without a proxy). By enabling the go module feature and setting GOPROXY, packages can be retrieved more fast from a CDN like mirror.

  ::

    # export GO111MODULE=on
    export GO111MODULE=auto
    # export GOPROXY=https://goproxy.cn
    export GOPROXY=https://goproxy.io
    go get -u <package>

**Tips:** the same problem will be hit when build docker images for go apps. This can be worked around by setting ENV values in a dockerfile as below:

::

  FROM ......
  ENV GO111MODULE=on
  ENV GOPROXY=https://goproxy.io
  ......

Reference:

- `A Global Proxy for Go Modules <https://goproxy.io/>`_

The replace directive with go module
-------------------------------------

**replace** directive allows to replace module/package dependencies with local copies or alternative repositories. It can be added before/after the require directive in go.mod

::

  replace github.com/user1/pkg1 => /local/dir/pkg1
  replace golang.org/google/pkg1 => github.com/google/pkg1

Beside the above mentioned method(edit go.mod) directly, below commands can also be leveraged for the same purpose:

::

  go mod edit -replace github.com/user1/pkg1=/local/dir/pkg1

Debug with delve
-----------------

`Github Reference <https://github.com/go-delve/delve>`_


::

  # if dlv is executed from the directory where main.go is defined
  dlv debug
  # if dlv is run from other dirs
  dlv debug <package name>
  # pass parameters
  dlv debug -- -arg1 value1

Docs for builtin types and functions
-------------------------------------

::

  go doc builtin
  go doc builtin.<symbol>

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

Use consul for go-micro
------------------------

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
--------------------------------------------

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

go-micro metadata
-------------------

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
