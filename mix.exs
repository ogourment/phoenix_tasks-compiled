defmodule Mix.Tasks.Compile.BinaryPhoenixTasks do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "ebin/Elixir.PhoenixTasks.Adapter.beam" =>
      "65E1CAE56882D499355312D8107E80261863892CA7770E95F604FA48BD6E8006",
    "ebin/Elixir.PhoenixTasks.Command.beam" =>
      "05B0806FAE2AF942FB2677DFDB20FC4FC4267078553544B496FDF89DB5BA5D5E",
    "ebin/Elixir.PhoenixTasks.Data.beam" =>
      "DDC6DA8B8742A9CBCC6AC0F3EEE68D29E15CBEA9F783FE3A084C62F5A3CB9804",
    "ebin/Elixir.PhoenixTasks.Observation.beam" =>
      "349EDF97467491D5E8EEF2E7DA4D7DC5BFB8574A7B5B5AC73EA2BAEED40E895F",
    "ebin/Elixir.PhoenixTasks.Planner.beam" =>
      "8698237CE13AB46A9E17D6BA85EA24BEA66808CC9D8545E3161D6C8ACCC80D06",
    "ebin/Elixir.PhoenixTasks.Projection.beam" =>
      "A8ACF37B8CA2132C9E4CC48847D971536E527EFA280AFE9CFFC5F633475A519B",
    "ebin/Elixir.PhoenixTasks.Snooze.beam" =>
      "6B015A0A7DE5F286372CCA9C0315CCC276E3D87A7251B82CEE8F800661F0C487",
    "ebin/Elixir.PhoenixTasks.Source.beam" =>
      "3A3400216995B817AB083085CB0CD6D800465602D61AF41C32ED8AD295F012FD",
    "ebin/Elixir.PhoenixTasks.SourceKey.beam" =>
      "648831E7EA10EB56E7690497DCFD44AFC62AF23BC3829FF9E02DE0B6BAE8D6B4",
    "ebin/Elixir.PhoenixTasks.beam" =>
      "C2F33C9F421E36ACC60DFB4FC835DB9732097F3D4250380AE18A0D7FC270C189",
    "ebin/phoenix_tasks.app" => "F71459FF42448BDA89FEBF69F967393B886F476B0D13059EBBEE04E0D00EAC58"
  }

  @impl true
  def run(_args) do
    series = Version.parse!(System.version()) |> Map.take([:major, :minor])

    unless series == %{major: 1, minor: 20} and System.otp_release() == "29" do
      Mix.raise("phoenix_tasks requires a binary distribution for Elixir 1.20.x / OTP 29")
    end

    for {path, expected} <- @checksums do
      bytes = File.read!(Path.join(@root, path))

      unless Base.encode16(:crypto.hash(:sha256, bytes)) == expected do
        Mix.raise("phoenix_tasks artifact checksum mismatch: #{path}")
      end

      if String.starts_with?(path, "ebin/") do
        target = Path.join(Mix.Project.compile_path(), Path.basename(path))
        File.mkdir_p!(Path.dirname(target))
        File.write!(target, bytes)
      end
    end

    {:ok, []}
  end
end

defmodule Compiled.PhoenixTasks.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_tasks,
      version: "0.0.2",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_tasks],
      deps: []
    ]
  end

  def application, do: [extra_applications: [:crypto]]
end
