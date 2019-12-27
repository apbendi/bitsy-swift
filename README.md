# BitsySwift

BitsySwift is a compiler for the [Bitsy](https://github.com/apbendi/bitsyspec)
language implemented in Swift. It is currently the canonical implementation of Bitsy.

## Bitsy

[Bitsy](https://github.com/apbendi/bitsyspec) is a programming language which
aims to be the best language to implement
when building your first compiler or interpreter. It is a resource for
programmers learning about language implementation.

To learn more about Bitsy or to try implementing it yourself, in your favorite
language, check out the runnable, test based language specification,
[BitsySpec](https://github.com/apbendi/bitsyspec).

You can read more about the motivation behind creating Bitsy on the
[ScopeLift Blog](http://www.scopelift.co/blog/introducing-bitsy-the-first-language-youll-implement-yourself).

I spoke about creating Bitsy and implementing it in Swift at several conferences in 2016. You can [watch the talk on YouTube](https://youtu.be/XkjySn0nwzQ).


## Requirements

This version of BitsySwift has been tested with:

 * macOS 10.14 (Mojave) or later
 * [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) 11.3
 * Swift 5.0

Linux support is currently limited by
[Swift Foundation](https://github.com/apple/swift-corelibs-foundation) but
should come eventually.

## Installation

To 'install' the compiler, simply clone and build the repository. You must have
[Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
and the `xcodebuild` utility installed.

```bash
git clone https://github.com/apbendi/bitsy-swift.git
cd bitsy-swift
./build.sh
```

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
user input, though the binaries themselves run fine.
Any `bash` experts know why?*

Alternatively, you may directly use the `bitsy-swift` command line utility
directly for additional options:

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

## Resources

While Bitsy has been created partially in response to a perceived lack of approachable
resources for learning language implementation, there are still some good
places to start.

 * [Let's Build a Compiler](http://www.compilers.iecc.com/crenshaw/); this
   paper from the late 80's (!) is an excellent introduction to compilation.
   The biggest downside is the use of
   [Pascal](https://en.wikipedia.org/wiki/Pascal_%28programming_language%29)
   and [m68K](https://en.wikipedia.org/wiki/Motorola_68000) assembly. While working
   through this tutorial, I
   [partially translate](https://github.com/apbendi/LetsBuildACompilerInSwift)
   his code to Swift.
 * [The Super Tiny Compiler](https://github.com/thejameskyle/the-super-tiny-compiler)
   is a great resource by James Kyle- a minimal, extremely well commented compiler
   written in JavaScript. Be sure to also checkout the associated
   [conference talk](https://www.youtube.com/watch?v=Tar4WgAfMr4)
 * [How to implement a programming language in JavaScript](http://lisperator.net/pltut/)
   is a slightly more advanced resource which is, for better or worse, also
   written in JavaScript.
 * [A Nanopass Framework for Compiler Education (PDF)](http://www.cs.indiana.edu/~dyb/pubs/nano-jfp.pdf)
 * [Stanford Compiler Course](https://www.youtube.com/watch?v=sm0QQO-WZlM&list=PLFB9EC7B8FE963EB8)
   with Alex Aiken; an advanced resource for learning some theory and going
   deeper.

## Contributing

Contributions of all types are welcome! Open an issue, create a pull request,
or just ask a question. The only requirement is that you be respectful of
others.

Please checkout the [BitsySpec](https://github.com/apbendi/bitsyspec) repo and join
the discussion to codify version 1.0 of the Bitsy language specification.
