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
end