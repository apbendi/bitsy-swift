# bitsy-swift

bitsy-swift is a compiler for the [Bitsy](#bitsy) language implemented in Swift. It is
currently the canonical implementation of Bitsy.

## Bitsy

[Bitsy](https://github.com/apbendi/bitsyspec) is a programming language which
aims to be the best language to target
when building your first compiler or interpreter. It is a resource for
programmers learning about language implementation.

To learn more about Bitsy or to try implementing it yourself, in your favorite
language, check out the runnable, test based language specification,
[bitsyspec](https://github.com/apbendi/bitsyspec).

## Installation

To 'install' the compiler, simply clone and build the repository. You must have
Xcode and the `xcodebuild` utility installed.

```bash
git clone https://github.com/apbendi/bitsy-swift.git
cd bitsy-swift
./build.sh
```

## Requirements

This version of bitsy-swift has been tested with:

 * OS X 10.11 (El Capitan)
 * Xcode 7.3.1
 * Swift 2.2

Xcode 8, macOS Sierra, and Swift 3 support is forthcoming. Linux
support is currently limited by
[Swift Foundation](https://github.com/apple/swift-corelibs-foundation) but
should come eventually.

## Usage

Once built, you can use the `runbitsy` script to conveniently build and immediately
run any `.bitsy` file.

```bash
./runbitsy samples/collatz.bitsy # Print the Collatz sequence for 7
22
11
34
17
52
26
13
40
20
10
5
16
8
4
2
1
```

*Note: The `runbitsy` script currently hangs for Bitsy programs which accept
user input. Any `bash` experts know why?*

Alternatively, you may directly use the bitsy-swift command line utility
for additional options:

```bash
bin/bitsy-swift --help
Usage: bin/bitsy-swift [options]
  -v, --version:
      Print the version of bitsy-swift
  -h, --help:
      Display bitsy-swift usage
  -c, --read-cli:
      Read Bitsy code from the command line, terminated by a '.'
  -o, --output:
      Specify a name for the binary output
  -e, --emit-cli:
      Emit intermediate compilation to command line
  -r, --run-delete:
      Immediately run and delete the compiled binary
  -i, --retain-intermediate:
      Retain results of intermediate representation
```

## Contributing

Contributions of all types are welcome! Open an issue, create a pull request,
or just ask a question. The only requirement is that you be respectful of
others.

Please checkout the [bitsyspec](https://github.com/apbendi/bitsyspec) repo and join
the discussion to codify version 1.0 of the Bitsy language specification.
