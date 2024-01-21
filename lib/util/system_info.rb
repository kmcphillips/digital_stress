# frozen_string_literal: true
module SystemInfo
  extend self

  def flyio?
    ENV["FLY_ALLOC_ID"].present?
  end

  def region
    (ENV["FLY_REGION"] || "?").upcase if flyio?
  end

  def instance
    ENV["FLY_ALLOC_ID"] if flyio?
  end

  def memory
    ENV["FLY_VM_MEMORY_MB"] if flyio?
  end

  def ip_address
    system_call("hostname -I").split(" ").first.presence
  end

  def hostname
    system_call("hostname").split.first.presence
  end

  def git_revision
    system_call("git rev-parse --short HEAD").strip.presence rescue nil
  end

  def recently_deployed?
    flyio? && uptime_seconds < 180
  end

  def short_summary
    if flyio?
      "fly.io #{ region }"
    else
      "#{ hostname }"
    end
  end

  def uptime_seconds
    system_call("cat /proc/uptime").split(" ").first.to_f.to_i
  end

  private

  def system_call(command)
    result = SystemCall.call(command)
    raise "`#{ command }` failed: #{ result.result }" unless result.success?
    result.result
  end
end
