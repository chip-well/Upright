class Upright::Maintenance < Upright::Incident
  STATUSES          = %w[ scheduled in_progress completed ]
  TERMINAL_STATUSES = %w[ completed ]
  IMPACTS           = %w[ maintenance ]

  validates :ends_at, presence: true
  validate :ends_after_start

  before_validation :set_maintenance_impact

  def maintenance? = true

  def auto_advance_status(now: Time.current)
    record_update(status: "in_progress", body: "Maintenance is underway.") if scheduled? && now >= starts_at
    record_update(status: "completed",  body: "Maintenance is complete.")  if in_progress? && now >= ends_at
  end

  private
    def set_maintenance_impact
      self.impact = "maintenance"
    end

    def ends_after_start
      errors.add(:ends_at, "must be after the start") if ends_at.present? && starts_at.present? && ends_at <= starts_at
    end
end
