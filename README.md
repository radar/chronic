# Chronic

[![Build Status](https://travis-ci.org/radar/chronic.svg?branch=master)](https://travis-ci.org/radar/chronic)

Like [Chronic](http://rubygems.org/gems/chronic), but for Elixir.

## Usage

Add it as a dependency to your project:

```elixir
defp deps do
  [
    {:chronic, git: "git://github.com/radar/chronic"},
 ]
end
```

Then you can use it wherever you wish:

```elixir
Chronic.parse("tuesday 9am")
```

Chronic will return `nil` if it doesn't recognise the format you've given it.
