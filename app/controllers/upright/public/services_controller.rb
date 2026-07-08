class Upright::Public::ServicesController < Upright::Public::BaseController
  def index
    @services = Upright::Service.public_facing
    @active_incidents = Upright::Incident.reactive.active.order(starts_at: :desc)
    @active_maintenances = Upright::Maintenance.active.order(:starts_at)
    @upcoming_maintenances = Upright::Maintenance.upcoming.order(:starts_at)
    expires_in 15.seconds, public: true
  end
end
