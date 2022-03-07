defmodule Conedeck.Scene.SysInfo do
  use Scenic.Scene
  alias Scenic.Graph
  require Logger
  import Scenic.Primitives
  import Scenic.Components

  def button_group(graph, index) do
    graph
    |> button("hello world",
      id: {index, 0},
      width: 100,
      height: 100,
      radius: 10,
      theme: %{border: :blue, background: :green, active: :blue, text: :white},
      translate: {0, 0}
    )
    |> button("hello world",
      id: {index, 1},
      width: 100,
      height: 100,
      radius: 10,
      theme: %{border: :blue, background: :green, active: :blue, text: :white},
      translate: {150, 0}
    )
    |> button("hello world",
      id: {index, 2},
      width: 100,
      height: 100,
      radius: 10,
      theme: %{border: :blue, background: :green, active: :blue, text: :white},
      translate: {300, 0}
    )
    |> button("hello world",
      id: {index, 3},
      width: 100,
      height: 100,
      radius: 10,
      theme: %{border: :blue, background: :green, active: :blue, text: :white},
      translate: {450, 0}
    )
    |> button("hello world",
      id: {index, 4},
      width: 100,
      height: 100,
      radius: 10,
      theme: %{border: :blue, background: :green, active: :blue, text: :white},
      translate: {600, 0}
    )
  end

  def init(_, opts) do
    viewport = opts[:viewport]

    graph =
      Graph.build(font_size: 22, font: :roboto_mono)
      |> group(&button_group(&1, 0), t: {50, 10})
      |> group(&button_group(&1, 0), t: {50, 200})
      |> group(&button_group(&1, 0), t: {50, 350})
      |> push_graph()

    {:ok, %{graph: graph, viewport: viewport}}
  end

  def filter_event(info, _from, state) do
    Logger.info(%{unhandled_event: info})
    Scenic.ViewPort.set_root(state.viewport, {Conedeck.PictureFrame, nil})

    {:noreply, state}
  end
end
