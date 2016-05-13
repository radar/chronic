defmodule Chronic.CLI do
  def main(args) do
    time = Enum.join(args, " ")
    case Chronic.parse(time) do
      { :ok, ndt, _offset } ->
        IO.puts Calendar.Strftime.strftime!(ndt, "%Y-%m-%d %T")
      _ -> 
        IO.puts IO.ANSI.red <> "Unrecognised time format."
    end
  end
end
