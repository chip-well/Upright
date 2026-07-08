class Upright::Public::IncidentsController < Upright::Public::BaseController
  def show
    @incident = Upright::Incident.find(params[:id])
    expires_in 15.seconds, public: true
  end
end
