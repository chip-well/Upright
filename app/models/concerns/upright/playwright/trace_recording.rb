module Upright::Playwright::TraceRecording
  extend ActiveSupport::Concern

  included do
    attr_accessor :trace_path

    set_callback :page_ready, :before, :start_trace
    set_callback :page_close, :before, :stop_trace
  end

  private
    def trace_dir
      Upright.configuration.recording_base_dir
    end

    def start_trace
      context.tracing.start(screenshots: true, snapshots: true)
    end

    def stop_trace
      self.trace_path = trace_dir.join("#{SecureRandom.hex}.zip").to_s
      FileUtils.mkdir_p(trace_dir)
      context.tracing.stop(path: trace_path)
    rescue => error
      Rails.error.report(error)
      self.trace_path = nil
    end

    def attach_trace(probe_result)
      return unless trace_path && File.exist?(trace_path)

      File.open(trace_path, "rb") do |file|
        Upright::Artifact.new(name: "#{probe_name}.zip", content: file).attach_to(probe_result, timestamped: true)
      end

      FileUtils.rm(trace_path)
      self.trace_path = nil
    end

end
