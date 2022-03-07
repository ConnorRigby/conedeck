defmodule Conedeck.PictureFrame do
  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Components
  import Scenic.Primitives, only: [{:rect, 3}, {:update_opts, 2}]

  # @parrot_path :code.priv_dir(:conedeck)
  #              |> Path.join("/static/images/piss.png")
  # @parrot_hash Scenic.Cache.Support.Hash.file!( @parrot_path, :sha )

  @parrot_width 484
  @parrot_height 712

  # --------------------------------------------------------
  def init(first_scene, opts) do
    parrot_path =
      :code.priv_dir(:conedeck)
      |> Path.join("/static/images/conesad.png")

    parrot_hash = Scenic.Cache.Support.Hash.file!(parrot_path, :sha)
    viewport = opts[:viewport]

    # calculate the transform that centers the parrot in the viewport
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    position = {
      vp_width / 2 - @parrot_width / 2,
      vp_height / 2 - @parrot_height / 2
    }

    # load the parrot texture into the cache
    {:ok, _} = Scenic.Cache.Static.Texture.load(parrot_path, parrot_hash)

    # move the parrot into the right location
    graph =
      Graph.build()
      |> rect(
        {@parrot_width, @parrot_height},
        id: :parrot,
        fill: {:image, {parrot_hash, 100}}
      )
      |> button("back", t: {20, 20}, id: :back)
      |> Graph.modify(:parrot, &update_opts(&1, translate: position, scale: 0.5))
      |> push_graph()

    state = %{
      viewport: viewport,
      graph: graph,
      first_scene: first_scene,
      alpha: 0,
      parrot_hash: parrot_hash
    }

    {:ok, state}
  end

  def filter_event({:click, :back}, _from, state) do
    ViewPort.set_root(state.viewport, {Conedeck.Scene.SysInfo, nil})
    {:noreply, state}
  end
end
