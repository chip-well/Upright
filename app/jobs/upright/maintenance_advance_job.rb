class Upright::MaintenanceAdvanceJob < Upright::ApplicationJob
  queue_as :default

  def perform
    Upright::Maintenance.where(resolved_at: nil).find_each(&:auto_advance_status)
  end
end
