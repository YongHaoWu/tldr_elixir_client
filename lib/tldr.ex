defmodule TLDR do
  use HTTPoison.Base
  import IO.ANSI

  def main(args) do
    args |> parse_args |> process |> IO.puts
  end

  defp parse_args(args) do
    options = OptionParser.parse(args, switches: [help: :boolean], aliases: [h: :help])
    case options do
      { [help: true], _, _ } -> :help
      { _, [], _ } -> :help
      { _,  terms , _ } ->
        Enum.join(terms, " ") |> String.strip
    end
  end

  defp process(:help) do
    """
    Usage:
      tldr term
    Options:
      -h, [--help]  # Show this help message and quit.

    Description:
      Search for a definition on TLDR.
    """
  end
  defp process(""), do: process(:help)
  defp process(term), do: describe(term)

  def process_url(url) do
    "https://raw.github.com/rprieto/tldr/master/pages/" <> url
  end
  def process_request_headers(headers), do: headers ++ [{"User-agent", "TLDR Elixir client"}]

  defp describe(term) do
    response = get("common/#{term}.md")
    if response.status_code == 404 do
      "Not found"
    else
      response.body |> format
    end
  end

  defp format(markdown) do
    String.split(markdown, ~r/\n/)
    |> Enum.drop(2)
    |> Enum.map(fn(line) ->
      format_line(line) <> reset
    end)
    |> Enum.join("\n")
  end

  defp format_line("> " <> line) do
    escape(white <> line)
  end
  defp format_line("- " <> line) do
    escape(green <> line)
  end
  defp format_line("`" <> line) do
    escape(black_background <> white <> String.rstrip(line, ?`))
  end
  defp format_line(line), do: line
end
