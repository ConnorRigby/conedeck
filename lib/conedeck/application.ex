defmodule Conedeck.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Conedeck.Supervisor]
    maybe_start_distribution()

    main_viewport_config = Application.get_env(:conedeck, :viewport)

    children =
      [
        {Scenic, viewports: [main_viewport_config]}
        # Children for all targets
        # Starts a worker by calling: Conedeck.Worker.start_link(arg)
        # {Conedeck.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Conedeck.Worker.start_link(arg)
      # {Conedeck.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Conedeck.Worker.start_link(arg)
      # {Conedeck.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:conedeck, :target)
  end

  def maybe_start_distribution() do
    _ = :os.cmd('epmd -daemon')
    {:ok, hostname} = :inet.gethostname()

    case Node.start(:"conedeck@#{hostname}.local") do
      {:ok, _pid} ->
        Node.set_cookie(:KFUYVQEXKNOEJXOBANFE)
        Logger.info("Distribution started at conedeck@#{hostname}.local")

      {:error, {:already_started, _}} ->
        Node.set_cookie(:KFUYVQEXKNOEJXOBANFE)
        Logger.info("Distribution started at conedeck@#{hostname}.local")

      _error ->
        Logger.error("Failed to start distribution")
    end
  end
end
