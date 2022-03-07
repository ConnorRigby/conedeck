defmodule Conedeck.Scene.Splash do
  @moduledoc """
  Sample splash scene.

  This scene demonstrate a very simple animation and transition to another scene.

  It also shows how to load a static texture and paint it into a rectangle.
  """

  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives, only: [{:rect, 3}, {:update_opts, 2}]

  # @parrot_path :code.priv_dir(:conedeck)
  #              |> Path.join("/static/images/piss.png")
  # @parrot_hash Scenic.Cache.Support.Hash.file!( @parrot_path, :sha )

  @parrot_width 800
  @parrot_height 480

  @animate_ms 30
  @finish_delay_ms 1000

  # --------------------------------------------------------
  def init(first_scene, opts) do
    parrot_path =
      :code.priv_dir(:conedeck)
      |> Path.join("/static/images/splash.png")

    parrot_hash = Scenic.Cache.Support.Hash.file!(parrot_path, :sha)
    viewport = opts[:viewport]

    # calculate the transform that centers the parrot in the viewport
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    position = {
      vp_width / 2 - @parrot_width / 2,
      vp_height / 2 - @parrot_height / 2
    }

    # load the parrot texture into the cache
    Scenic.Cache.Static.Texture.load(parrot_path, parrot_hash)

    # move the parrot into the right location
    graph =
      Graph.build()
      |> rect(
        {@parrot_width, @parrot_height},
        id: :parrot,
        fill: {:image, {parrot_hash, 0}}
      )
      |> Graph.modify(:parrot, &update_opts(&1, translate: position))
      |> push_graph()

    # start a very simple animation timer
    {:ok, timer} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      viewport: viewport,
      timer: timer,
      graph: graph,
      first_scene: first_scene,
      alpha: 0,
      parrot_hash: parrot_hash
    }

    {:ok, state}
  end

  # --------------------------------------------------------
  # A very simple animation. A timer runs, which increments a counter. The counter
  # Is applied as an alpha channel to the parrot png.
  # When it is fully saturated, transition to the first real scene
  def handle_info(
        :animate,
        %{timer: timer, alpha: a} = state
      )
      when a >= 256 do
    :timer.cancel(timer)
    Process.send_after(self(), :finish, @finish_delay_ms)
    {:noreply, state}
  end

  def handle_info(:finish, state) do
    go_to_first_scene(state)
    {:noreply, state}
  end

  def handle_info(:animate, %{alpha: alpha, graph: graph} = state) do
    graph =
      graph
      |> Graph.modify(:parrot, &update_opts(&1, fill: {:image, {state.parrot_hash, alpha}}))
      |> push_graph()

    {:noreply, %{state | graph: graph, alpha: alpha + 2}}
  end

  # --------------------------------------------------------
  # short cut to go right to the new scene on user input
  def handle_input({:cursor_button, {_, :press, _, _}}, _context, state) do
    go_to_first_scene(state)
    {:noreply, state}
  end

  def handle_input({:key, _}, _context, state) do
    go_to_first_scene(state)
    {:noreply, state}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

  # --------------------------------------------------------
  defp go_to_first_scene(%{viewport: vp, first_scene: first_scene}) do
    ViewPort.set_root(vp, {first_scene, nil})
  end
end
