# Chronic

[![Build Status](https://travis-ci.org/radar/chronic.svg?branch=master)](https://travis-ci.org/radar/chronic)
[![Module Version](https://img.shields.io/hexpm/v/chronic.svg)](https://hex.pm/packages/chronic)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/chronic/)
[![Total Download](https://img.shields.io/hexpm/dt/chronic.svg)](https://hex.pm/packages/chronic)
[![License](https://img.shields.io/hexpm/l/chronic.svg)](https://github.com/radar/chronic/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/radar/chronic.svg)](https://github.com/radar/chronic/commits/master)

Like [Chronic](http://rubygems.org/gems/chronic), but for Elixir.

## Usage

Add it as a dependency to your project:

```elixir
defp deps do
  [
    {:chronic, "~> 3.2"},
  ]
end
```

Then you can use it wherever you wish:

```elixir
{ :ok, time, offset } = Chronic.parse("tuesday 9am")
```

The time returned is a `NaiveDateTime` from Elixir and the `offset` returned is a time zone offset.

### Chronic uses universal time by default

Chronic works based off the current UTC time by default. This is important to know because of how Chronic behaves. If you're in UTC +10 (Melbourne), like I am, and it's currently Tuesday, 25th September 2018 at 1pm in Melbourne, Chronic will think it is "currently" 3am -- because it is in UTC time.

So if you ask Chronic what "Tuesday at 12pm" looks like, it will tell give you a time for _today_:

```elixir
{:ok, time, offset} = Chronic.parse("Tuesday 12pm")
{:ok, ~N[2018-09-25 12:00:00.000000], 0}
```

This is probably not what you want because it's a date in Melbourne's past but UTC's future. To fix this, you can use the `currently` option and pass it your local time:

```elixir
{:ok, time, offset} = Chronic.parse("tuesday at 12pm", currently: :calendar.local_time)
{:ok, ~N[2018-10-02 12:00:00.000000], 0}
```

This is a better time because it's in the future; probably what you want.

However, it's important to note here that the `offset` value will be `0` rather than the correct timezone, so it's better ignored in this case.


### Bad / Unknown Formats

If Chronic encounters a format it doesn't recognise, it will return an error tuple:

```elixir
{ :error, :unknown_format } = Chronic.parse("definitely not a known format, no siree")
```

If `NaiveDateTime` doesn't know what you mean (i.e. if you ask for a date such as "January 32nd"), then you'll see this error instead:

```elixir
{:error, :invalid_datetime} = Chronic.parse("January 32nd")
```


If you're not sure what you're going to get back, use a `case`:

```elixir
input = "some user input goes here"
case Chronic.parse(input) do
  { :ok, time, offset } ->
    # do something with time + offset
  { :error, _ } ->
    # present a good error message to the user
end
```

## Copyright and License

Copyright (c) 2016 Ryan Bigg

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
