defmodule Mix.Tasks.Reload do
  use Mix.Task
  require Logger

  def run(opts) do
    {args, _, _} = OptionParser.parse(opts, strict: [hostname: :string], aliases: [h: :hostname])
    {:ok, _} = Node.start(:reloader@localhost)
    Node.set_cookie(:KFUYVQEXKNOEJXOBANFE)
    Logger.info("Distribution started at reloader@localhost")
    remote_node = :"conedeck@#{args[:hostname]}"
    true = Node.connect(remote_node)
    Logger.info("Distribution connected to conedeck@#{args[:hostname]}")
    :ok = Application.ensure_loaded(:conedeck)
    {:ok, modules} = :application.get_key(:conedeck, :modules)

    for module <- modules do
      IEx.Helpers.nl([remote_node], module)
      Logger.info("Reloaded #{module}")
    end

    :rpc.call(remote_node, Application, :stop, [:conedeck])
    :rpc.call(remote_node, Application, :ensure_all_started, [:conedeck])
  end
end
