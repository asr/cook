_cook_
======

Description
-----------

A program and library version of Augustsson’s paper describing how to
implement the λ-calculus in Haskell in four different ways.

See below the orignal README.

Installation
------------

```bash
$ git clone -b prg-lib --single-branch https://github.com/asr/cook
$ cd cook
$ cabal install
```

Original README
===============

A runnable version of Augustsson’s paper describing how to implement the λ-calculus in Haskell in four different ways.


Usage
-----

    $ cook S <timing.lam
    \x44. \x43. x43

    $ cook U <timing.lam
    \x13663534. \x13663535. x13663535

    $ cook H <timing.lam
    \x0. \x1. x1

    $ cook D <timing.lam
    \x0. \x1. x1


References
----------

• Augustsson, L. (2006) [“λ-calculus cooked four ways”](doc/pdf/augustsson-2006.pdf)


About
-----

Packaged by [Miëtek Bak](https://mietek.io/).
