require "test_helper"

class Upright::IncidentTest < ActiveSupport::TestCase
  setup { travel_to Time.utc(2026, 6, 15, 12) }

  test "a reactive incident is valid and is not a maintenance" do
    incident = upright_incidents(:reactive_resolved)

    assert incident.valid?
    assert_not incident.maintenance?
  end

  test "rejects a status outside the reactive lifecycle" do
    incident = upright_incidents(:reactive_resolved)
    incident.status = "scheduled"

    assert_not incident.valid?
    assert incident.errors[:status].any?
  end

  test "record_update appends an update, moves status, and stamps resolved_at on a terminal status" do
    incident = activate(upright_incidents(:reactive_resolved))

    incident.record_update(status: "monitoring", body: "Watching recovery.")
    assert_equal "monitoring", incident.reload.status
    assert_nil incident.resolved_at
    assert_equal 2, incident.updates.count

    incident.record_update(status: "resolved", body: "All clear.")
    assert_equal "resolved", incident.reload.status
    assert_not_nil incident.resolved_at
  end

  test "record_update returns an unpersisted update and leaves the incident unchanged when invalid" do
    incident = activate(upright_incidents(:reactive_resolved))

    update = incident.record_update(status: "", body: "Something changed.")

    assert_not update.persisted?
    assert update.errors[:status].any?
    assert_equal "investigating", incident.reload.status
  end

  test "record_update accepts a blank message" do
    incident = activate(upright_incidents(:reactive_resolved))

    update = incident.record_update(status: "monitoring", body: "")

    assert update.persisted?
    assert_equal "monitoring", incident.reload.status
  end

  test "creating an incident seeds an initial update from the default status" do
    incident = Upright::Incident.create!(title: "x", impact: "minor", starts_at: Time.current, body: "Looking into it.")

    assert_equal "investigating", incident.status
    assert_equal 1, incident.updates.count
    assert_equal "Looking into it.", incident.updates.first.body
  end

  test "active_statuses maps active reactive incident impact to a page status" do
    activate upright_incidents(:reactive_resolved), impact: "major"

    assert_equal [ :partial_outage ], Upright::Incident.active_statuses
  end

  test "service_codes= assigns affected services and rejects unknown codes" do
    incident = upright_incidents(:reactive_resolved)

    incident.service_codes = [ "example_app" ]
    assert incident.save
    assert_equal [ "example_app" ], incident.reload.service_codes

    incident.service_codes = [ "does_not_exist" ]
    assert_not incident.valid?
  end

  test "active, upcoming, and past scopes key off timestamps and resolved_at" do
    active = activate(upright_incidents(:reactive_other))
    resolved = upright_incidents(:reactive_resolved)

    assert_includes Upright::Incident.active, active
    assert_not_includes Upright::Incident.active, resolved
    assert_includes Upright::Incident.past, resolved
  end

  test "reactive scope excludes the maintenance subclass" do
    assert_includes Upright::Incident.reactive, upright_incidents(:reactive_resolved)
    assert_not_includes Upright::Incident.reactive, upright_incidents(:in_progress)
  end

  test "for_service filters by affected service code" do
    incident = upright_incidents(:reactive_with_service)

    assert_includes Upright::Incident.for_service("example_app"), incident
    assert_not_includes Upright::Incident.for_service("internal_tools"), incident
  end

  private
    def activate(incident, **overrides)
      incident.update!({ status: "investigating", starts_at: 1.hour.ago, resolved_at: nil }.merge(overrides))
      incident
    end
end
