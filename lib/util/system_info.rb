# frozen_string_literal: true
module SystemInfo
  extend self

  def digitalocean?
    File.exist?("/opt/digitalocean") || ip_address.match?(/app[0-9]/)
  end

  def flyio?
    ENV["FLY_ALLOC_ID"].present?
  end

  def region
    (ENV["FLY_REGION"] || "?").upcase if SystemInfo.flyio?
  end

  def instance
    ENV["FLY_ALLOC_ID"] if SystemInfo.flyio?
  end

  def memory
    ENV["FLY_VM_MEMORY_MB"] if SystemInfo.flyio?
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
    SystemInfo.flyio? && (uptime_seconds || 180) < 180
  end

  def uptime_seconds
    if SystemInfo.flyio?
      system_call("cat /proc/uptime").split(" ").first.to_f.to_i
    else
      nil
    end
  end

  private

  def system_call(command)
    result = SystemCall.call(command)
    raise "`#{ command }` failed: #{ result.result }" unless result.success?
    result.result
  end
end
