# Packager

[![Gem Version](https://img.shields.io/gem/v/packager.svg)](https://rubygems.org/gems/packager-dsl)
[![Gem Downloads](https://img.shields.io/gem/dt/packager.svg)](https://rubygems.org/gems/packager-dsl)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/robkinyon/ruby-packager)

[![Build Status](https://img.shields.io/travis/robkinyon/ruby-packager.svg)](https://travis-ci.org/robkinyon/ruby-packager)
[![Code Climate](https://img.shields.io/codeclimate/github/robkinyon/ruby-packager.svg)](https://codeclimate.com/github/robkinyon/ruby-packager)
[![Code Coverage](https://img.shields.io/codecov/c/github/robkinyon/ruby-packager.svg)](https://codecov.io/github/robkinyon/ruby-packager)
[![Inline docs](http://inch-ci.org/github/robkinyon/ruby-packager.png)](http://inch-ci.org/github/robkinyon/ruby-packager)

## TL;DR

Create the following file:
```ruby
package "foo" do
  version "0.0.1"
  type "<fpm type>"
  
  file {
    source "/some/place/in/filesystem"
    dest "/some/place/to/put/it"
  }

  files {
    source "/some/bunch/of/files/*"
    dest "/some/other/place"
  }
end
```

Invoke the associated `packager` script as follows:
```shell
$ packager execute <filename>
```

You now have `foo-0.0.1.x86_64.deb` with several files in it wherever you
invoked `packager`.

## DSL

* package <name>
   * name    String
   * version VersionString
   * type String Valid FPM package type
   * file / files
      * source String
      * dest   String
   * requires Array[String]
   * provides Array[String]

## Dry run

`packager execute dryrun <filename>`

The Package creation can be tested prior to creation with a dryrun. This will
only print the fpm command that the passed DSL will run. `dryrun` must be passed
after `execute` and before the DSL file name.

```bash
09:19 PM william$ packager execute dryrun ../package.dsl 
Dry run! This has not run or changed anything
fpm --name my-test-package --version 0.0.1 --depends ["sshfs", "libpam-systemd"] -s empty -t deb
```

This is the passed DSL file

```ruby
package 'my-test-package' do
  version '0.0.1'
  type 'deb'
  requires [
    'sshfs',
    'libpam-systemd',
  ]

end
```
