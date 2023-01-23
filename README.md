# Lester

Minimal Lua test framework.

Lester is a minimal unit testing framework for Lua with a focus on being simple to use.

It is highly inspired by
[Busted](http://olivinelabs.com/busted/) and [Lust](https://github.com/bjornbytes/lust).
It was mainly created to replace Busted without dependencies in the
[Nelua](https://github.com/edubart/nelua-lang) compiler.

[![asciicast](https://asciinema.org/a/GihfI07vCt9Q7cvL6xCtnoNl1.svg)](https://asciinema.org/a/GihfI07vCt9Q7cvL6xCtnoNl1)

## Features

* Minimal, just one file.
* Self contained, no external dependencies.
* Simple and hackable when needed.
* Use `describe` and `it` blocks to describe tests.
* Supports `before` and `after` handlers.
* Supports marking tests as disabled to be skipped.
* Colored output.
* Configurable via the script or with environment variables.
* Quiet mode, to use in live development.
* Optionally filter tests by name.
* Show traceback on errors.
* Show time to complete tests.
* Works with Lua 5.1+.
* Efficient.

## Usage

Copy `lester.lua` file to a project and require it,
which returns a table that includes all of the functionality:

```lua
local lester = require 'lester'
local describe, it, expect = lester.describe, lester.it, lester.expect

-- Customize lester configuration.
lester.show_traceback = false

describe('my project', function()
  lester.before(function()
    -- This function is run before every test.
  end)

  describe('module1', function() -- Describe blocks can be nested.
    it('feature1', function()
      expect.equal('something', 'something') -- Pass.
    end)

    it('feature2', function()
      expect.truthy(false) -- Fail.
    end)

    local feature3_test_enabled = false
    it('feature3', function() -- This test will be skipped.
      expect.truthy(false) -- Fail.
    end, feature3_test_enabled)
  end)
end)

lester.report() -- Print overall statistic of the tests run.
lester.exit() -- Exit with success if all tests passed.
```

## Customizing output with environment variables

To customize the output of lester externally,
you can set the following environment variables before running a test suite:

* `LESTER_QUIET="true"`, omit print of passed tests.
* `LESTER_COLORED="false"`, disable colored output.
* `LESTER_SHOW_TRACEBACK="false"`, disable traceback on test failures.
* `LESTER_SHOW_ERROR="false"`, omit print of error description of failed tests.
* `LESTER_STOP_ON_FAIL="true"`, stop on first test failure.
* `LESTER_UTF8TERM="false"`, disable printing of UTF-8 characters.
* `LESTER_FILTER="some text"`, filter the tests that should be run.

Note that these configurations can be changed via script too, check the documentation.

## Customizing output with command line arguments

You can also customize output using command line arguments
if `lester.parse_args()` is called at startup.

The following command line arguments are available:

* `--quiet`, omit print of passed tests.
* `--no-quiet`, show print of passed tests.
* `--no-color`, disable colored output.
* `--no-show-traceback`, disable traceback on test failures.
* `--no-show-error`, omit print of error description of failed tests.
* `--stop-on-fail`, stop on first test failure.
* `--no-utf8term`, disable printing of UTF-8 characters.
* `--filter="some text"`, filter the tests that should be run.

## Documentation

The full API reference and documentation can be viewed in the
[documentation website](https://edubart.github.io/lester/).

## Install

You can use luarocks to install quickly:

```bash
luarocks install lester
```

Or just copy the `lester.lua` file, the library is self contained in this single file with no dependencies.

## Tests

To check if everything is working as expected under your machine run `lua tests.lua` or `make test`.

## License

MIT, see LICENSE for details.
