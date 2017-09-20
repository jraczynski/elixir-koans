defmodule Watcher do
  use ExFSWatch, dirs: ["lib/koans"]

  def start_link do
    start()
  end

  def callback(file, events)  do
    if Enum.member?(events, :modified) do
      file |> normalize |> reload
    end
  end

  defp reload(file) do
    if Path.extname(file) == ".ex" do
      try do
        file
        |> Code.load_file
        |> Enum.map(&(elem(&1, 0)))
        |> Enum.find(&Runner.koan?/1)
        |> Runner.modules_to_run
        |> Runner.run
      rescue
        e -> Display.show_compile_error(e)
      end
    end
  end

  defp normalize(file) do
    String.replace_suffix(file, "___jb_tmp___", "")
  end
end
