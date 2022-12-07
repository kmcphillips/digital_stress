# frozen_string_literal: true
module SystemInfo
  extend self

  def digitalocean?
    File.exists?("/opt/digitalocean") || ip_address.match?(/app[0-9]/)
  end

  def flyio?
    ENV["FLY_ALLOC_ID"].present?
  end

  def ip_address
    `hostname -I`.split(" ").first
  end

  def hostname
    `hostname`.strip
  end

  def region
    if SystemInfo.flyio?
      (ENV["FLY_REGION"] || "?").upcase
    end
  end

  def git_revision
    `git rev-parse --short HEAD`.strip rescue "unknown"
  end

  def recently_deployed?
    SystemInfo.flyio? && uptime_seconds < 180
  end

  def uptime_seconds
    if SystemInfo.flyio?
      `cat /proc/uptime`.split(" ").first.to_f.to_i
    else
      nil
    end
  end
end
