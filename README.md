[![.github/workflows/ruby.yml](https://github.com/TwP/bones/actions/workflows/ruby.yml/badge.svg)](https://github.com/TwP/bones/actions/workflows/ruby.yml)

# Mr Bones

Mr Bones is a handy tool that creates new Ruby projects from a code
skeleton. The skeleton contains some starter code and a collection of rake
tasks to ease the management and deployment of your source code. Several Mr
Bones plugins are available for creating git repositories, creating GitHub
projects, running various test suites and source code analysis tools.

https://rubygems.org/gems/bones

## Synopsis

To create a new "Get Fuzzy" project:

```sh
bones create get_fuzzy
```

If you ever get confused about what Mr Bones can do:

```sh
bones --help
```

After your project is created, you can view all the available configuration
options:

```sh
rake bones:options
```

Detailed information about the options (or a subset of options) can also be
displayed:

```sh
rake bones:help        #=> for all options
rake bones:help gem    #=> for the "gem" subset
```

## Features

Mr Bones is configurable, helpful, and it simplifies project development.

Mr Bones simplifies project creation by using a code template for generating
a new working area for your code. This skeleton is customizable, and you can
have multiple skeletons for various types of projects you work on - ruby
libraries, web applications, or even writing projects.

When working with Rake, Mr Bones provides a set of tasks that help simplify
common development tasks. These tasks include ...

* release announcements
* gem packaging and management
* releasing to rubygems.org
* documentation
* annotation listing (TODO, FIXME, etc)
* testing

The provided rake tasks are configured using a "Bones" configuration block in
the Rakefile. You can obtain a list of the available options and descriptive
help for each option by running the various "bones" tasks (use "rake -T" to
list the available tasks). Although there are many configuration options, the
vast majority of them have sensible defaults; tailor to suit your needs in the
Bones configuration block.

Mr Bones can be extended via plugins. The plugins provide new rake tasks and
configuration options for those tasks. Other developers can release plugins to
automate the use of their libraries in a bones enabled system.

Currently there are a "bones-git" plugin for interacting with github and git
repositories and a "bones-extras" plugin for working with Rcov, RubyForge,
and Rspec.

## Install

```sh
gem install bones
```

If you would like some extra functionality the following plugins can be
installed:

```sh
gem install bones-git
gem install bones-yard
gem install bones-rspec
gem install bones-rcov
```

A complete list of available plugins is available via the bones command:

```sh
bones plugins --all
```

The `bones-git` gem provides command line options for generating a git
repository and pushing to github upon creation. Rake tasks for working with
the git repository are also provided.

## Development

Download a copy of the source code from GitHub

```sh
git clone https://github.com/TwP/bones.git
```

Run the bootstrap script to install the development dependencies

```sh
script/bootstrap
```

You should now be able to run the test specs and see them pass

```sh
rake spec
```

## Acknowledgements

Ryan Davis and Eric Hodel and their Hoe gem (from which much of the Mr Bones
rake tasks have been stolen). The rails team and their source annotation
extractor. Bruce Williams for help in coming up with the project name. Ara T.
Howard for letting me squat in the codeforpeople rubyforge project.

