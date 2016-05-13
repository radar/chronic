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
{ :ok, time, offset } = Chronic.parse("tuesday 9am")
```

The time returned is a `Calendar.NaiveDateTime` from the [calendar package](https://github.com/lau/calendar). The `offset` returned is a time zone offset.

If Chronic encounters a format it doesn't recognise, it will return an error tuple:

```elixir
{ :error, :unknown_format } = Chronic.parse("definitely not a known format, no siree")
```

If you're not sure what you're going to get back, use a `case`:

```elixir
input = "some user input goes here"
case Chronic.parse(input) do
  { :ok, time, offset } ->
    # do something with time + offset
  { :error, :unknown_format } -> 
    # present a good error message to the user
end
```
