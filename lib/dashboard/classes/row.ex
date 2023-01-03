defmodule Dashboard.Classes.Row do
  @enforce_keys [:status, :event, :date, :start_time, :end_time]
  defstruct [
    :status,
    :event,
    :date,
    :start_time,
    :end_time,
    :error_message,
    conflicting_events: []
  ]
end
