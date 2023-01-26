defmodule DashboardWeb.CalendarLive.ClaimsFormComponent do
  use DashboardWeb, :live_component

  alias Plug.Conn.Query

  @impl true
  def update(%{id: id, uri: uri} = assigns, socket) do
    %URI{
      path: path,
      query: raw_query
    } = URI.parse(uri)

    query =
      case raw_query do
        nil -> %{}
        str -> Query.decode(str)
      end

    expand_query = Query.encode(Map.put(query, "expand-claims", id))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:expand, false)
     |> assign(:expand_uri, "#{path}?#{expand_query}")}
  end
end
