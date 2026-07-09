require "test_helper"

class Upright::Public::IncidentsControllerTest < ActionDispatch::IntegrationTest
  setup { on_subdomain Upright.configuration.public_status_subdomain }

  test "incident detail never shows the author" do
    incident = upright_incidents(:reactive_resolved)
    assert_equal "Lewis Buckley", incident.created_by

    get upright.public_incident_path(incident)

    assert_response :success
    assert_no_match(/Lewis Buckley/, response.body)
  end
end
