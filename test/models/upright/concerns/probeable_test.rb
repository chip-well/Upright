require "test_helper"

class Upright::ProbeableTest < ActiveSupport::TestCase
  # Minimal probe that includes Probeable without a YAML source,
  # so alert_severity is not defined by default (simulates missing field).
  class MinimalProbe
    include Upright::Probeable

    def probe_type = "test"
    def probe_target = "test"
    def on_check_recorded(_) = nil
  end

  # Probe with a fixed alert_severity method (e.g. a Playwright-style override).
  class ProbeWithSeverityMethod < MinimalProbe
    def alert_severity = "critical"
  end

  class ProbeWithInvalidSeverityMethod < MinimalProbe
    def alert_severity = "urgent"
  end

  # --- default behaviour ---

  test "defaults to :high when alert_severity is not defined" do
    probe = MinimalProbe.new
    assert_equal :high, probe.probe_alert_severity
  end

  test "defaults to :high when alert_severity is nil" do
    probe = MinimalProbe.new
    probe.stubs(:alert_severity).returns(nil)
    assert_equal :high, probe.probe_alert_severity
  end

  # --- valid values from YAML (FrozenRecord-based probes) ---

  test "returns :medium when alert_severity is set to medium in YAML" do
    probe = Upright::Probes::HTTPProbe.find_by(name: "MediumSeverity")
    assert_equal :medium, probe.probe_alert_severity
  end

  test "returns :high when alert_severity is set to high in YAML" do
    probe = Upright::Probes::HTTPProbe.find_by(name: "HighSeverity")
    assert_equal :high, probe.probe_alert_severity
  end

  test "returns :critical when alert_severity is set to critical in YAML" do
    probe = Upright::Probes::HTTPProbe.find_by(name: "CriticalSeverity")
    assert_equal :critical, probe.probe_alert_severity
  end

  # --- invalid values from YAML fall back to :high ---

  test "falls back to :high for an unrecognised alert_severity in YAML" do
    probe = Upright::Probes::HTTPProbe.find_by(name: "InvalidSeverity")
    assert_equal :high, probe.probe_alert_severity
  end

  # --- valid/invalid values from method overrides (e.g. Playwright probes) ---

  test "returns :critical when alert_severity method returns a valid value" do
    probe = ProbeWithSeverityMethod.new
    assert_equal :critical, probe.probe_alert_severity
  end

  test "falls back to :high when alert_severity method returns an invalid value" do
    probe = ProbeWithInvalidSeverityMethod.new
    assert_equal :high, probe.probe_alert_severity
  end
end
