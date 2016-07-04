defmodule Throttle.Supervisor do
  use Supervisor
  import Logger

  def start_link(burst_limit, interval = {amount, scale}) do
    Logger.debug "Starting Supervisor"
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup, burst_limit, interval)
    result
  end

  def start_workers(sup, burst_limit, interval) do
    {:ok, bucket_sup} = Supervisor.start_child(sup, supervisor(Throttle.BucketSupervisor, []))
    Supervisor.start_child(sup, worker(Throttle.BucketManager, [bucket_sup, burst_limit]))
    Supervisor.start_child(sup, worker(Throttle.Timer, [interval]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end
