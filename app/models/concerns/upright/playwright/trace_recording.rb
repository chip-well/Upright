module Upright::Playwright::TraceRecording
  extend ActiveSupport::Concern

  TRACE_VIEWER_URL = "https://trace.playwright.dev/?trace="

  included do
    attr_accessor :trace_path

    set_callback :page_ready, :before, :start_trace
    set_callback :before_close, :after, :stop_trace
  end

  private
    def trace_dir
      Upright.configuration.video_storage_dir
    end

    def record_trace?
      !Rails.env.test?
    end

    def start_trace
      return unless record_trace?

      context.tracing.start(screenshots: true, snapshots: true)
    end

    def stop_trace
      return unless record_trace?

      self.trace_path = trace_dir.join("#{SecureRandom.hex}.zip").to_s
      FileUtils.mkdir_p(trace_dir)
      context.tracing.stop(path: trace_path)
    end

    def attach_trace(probe_result)
      return unless trace_path && File.exist?(trace_path)

      File.open(trace_path, "rb") do |file|
        Upright::Artifact.new(name: "#{probe_name}.zip", content: file).attach_to(probe_result, timestamped: true)
      end

      FileUtils.rm(trace_path)
      self.trace_path = nil
    end

    def trace_viewer_url(artifact)
      blob_url = Rails.application.routes.url_helpers.rails_blob_url(artifact, expires_in: 24.hours)
      "#{TRACE_VIEWER_URL}#{CGI.escape(blob_url)}"
    end
end
