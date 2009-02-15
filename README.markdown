Xcode Goodies
=============

A collection of Xcode macros, scripts, templates, and other goodies for iPhone and Mac development.

CLANG
-----

To use the [LLVM/Clang Static Analyzer](http://clang.llvm.org/StaticAnalysis.html), you'll need to download and unpack the latest binaries:

        $ curl -OL http://checker.minormatter.com/checker-0.156.tar.bz2
        $ tar xjf checker-0.156.tar.bz2 -C /Users/mike/clang

Then add the path to the extracted directory to your PATH environment variable.
For example, you'd add this to your ~/.bash_profile:

        export CLANG=/Users/mike/clang/checker-0.156
        export PATH=$PATH:$CLANG

Screencast
----------

Check out the [Becoming Productive in Xcode](http://pragprog.com/screencasts/v-mcxcode/becoming-productive-in-xcode) screencasts for more tips and tricks!

