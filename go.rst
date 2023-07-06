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
    go get example.com/pkg

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

Manage dependencies w/ go get
-------------------------------

::

  # add a dependency w/ the latest version
  go get example.com/pkg
  # add/upgrade/downgrade a dependency w/ a specified version
  go get example.com/pkg@v1.2.3
  # update a dependency
  go get -u example.com/pkg
  # update a dependency w/ a patch release, such as bug patch releases
  go get -u=patch example.com/pkg
  # upgrade all dependencies
  go get -u ./...
  # upgrade all dependencies, includign test dependencies
  go get -t -u ./...
  # remove a dependency
  go get example.com/pkg@none

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

      import _ <package name>

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
  # Show the document for an object of the package/module
  go doc [-short|-all] [-src] <package>[.<object>]

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

select
--------

break for select
~~~~~~~~~~~~~~~~~~

::

  // for loop won't be stopped if break w/o using a lable
  t := time.NewTicker(3 * time.Second)
  loop:
  for {
    select {
      case <-a:
      // action 1
      case <-b:
      // action 2
      case <-t.C:
      break loop
    }
  }

turn off a case in select
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  for {
    select {
    case v, ok := <-in1:
      if !ok {
        in1 = nil // if in1 is closed, turn it off by assinging nil,
                  // otherwise, it will always be successful
      }
    case v, ok := <-in2:
      ...
    }
  }

return from function w/o return
--------------------------------

::

  // if a function is defined w/o any return,
  // return is valid and will just return from the function execution
  func t1() {
    // some actions
    return
  }
  func main() {
    t1()
  }

generics
-----------

::

  package main

  import "fmt"

  type Number interface {
      int64 | float64
  }

  func main() {
      ints := map[string]int64{
          "first": 34,
          "second": 12,
      }

      floats := map[string]float64{
          "first": 35.98,
          "second": 26.99,
      }

      fmt.Printf("Generic Sums: %v and %v\n",
          SumIntsOrFloats[string, int64](ints),
          SumIntsOrFloats[string, float64](floats))

      fmt.Printf("Generic Sums, type parameters inferred: %v and %v\n",
          SumIntsOrFloats(ints),
          SumIntsOrFloats(floats))

      fmt.Printf("Generic Sums with Constraint: %v and %v\n",
          SumNumbers(ints),
          SumNumbers(floats))
  }

  func SumIntsOrFloats[K comparable, V int64 | float64](m map[K]V) V {
      var s V
      for _, v := range m {
          s += v
      }
      return s
  }

  func SumNumbers[K comparable, V Number](m map[K]V) V {
      var s V
      for _, v := range m {
          s += v
      }
      return s
  }

go-swagger
------------

Install swagger CLI
~~~~~~~~~~~~~~~~~~~~

::

  go get -u -v github.com/go-swagger/go-swagger/cmd/swagger
  swagger --help
