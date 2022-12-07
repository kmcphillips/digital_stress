# frozen_string_literal: true
module SystemInfo
  extend self

  def digitalocean?
    File.exists?("/opt/digitalocean") || ip_address.match?(/app[0-9]/)
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

  def cpu
    ENV["FLY_VCPU_COUNT"] if SystemInfo.flyio?
  end

  def memory
    ENV["FLY_VM_MEMORY_MB"] if SystemInfo.flyio?
  end

  def ip_address
    `hostname -I`.split(" ").first
  end

  def hostname
    `hostname`.strip
  end

  def git_revision
    `git rev-parse --short HEAD`.strip rescue "unknown"
  end

  def recently_deployed?
    SystemInfo.flyio? && (uptime_seconds || 180) < 180
  end

  def uptime_seconds
    if SystemInfo.flyio?
      `cat /proc/uptime`.split(" ").first.to_f.to_i
    else
      nil
    end
  end
end
