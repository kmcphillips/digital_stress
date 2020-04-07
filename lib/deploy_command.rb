# frozen_string_literal: true
class DeployCommand < BaseCommand
  BASE_WORKING_DIR = "/home/deploy/apps/digital_stress/shared/deploy_from"
  CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#quigital",
    "duck-bot-test#general",
  ].freeze

  class DeployError < StandardError ; end

  def response
    channel = "#{ event.server&.name }##{ event.channel&.name }"
    return "Quack! Not permitted!" unless CHANNELS.include?(channel)

    if params.count == 0
      "Quack! What should I deploy?"
    elsif params.count > 1
      "Quack! Just deploy one thing."
    elsif params.first == "quigital"
      deploy("quigital")
    elsif params.first == "infohub" || params.first == "quigital_infohub"
      deploy("quigital_infohub")
    else
      "Quack! Don't know how to deploy that."
    end
  end

  private

  def deploy(app)
    working_dir = "#{ BASE_WORKING_DIR }/#{app}"

    @event.respond(":rocket: Deploying #{ app }")

    begin
      Bundler.with_clean_env do
        run_command("git pull", working_dir: working_dir)
        run_command("bundle install", working_dir: working_dir)
        run_command("bundle exec cap production deploy", working_dir: working_dir)
      end
    rescue DeployError => e
      return e.message
    end

    ":tada: Quack! Deploy complete."
  end

  def run_command(command, working_dir:)
    message = @event.respond("`#{ command }`")
    output = `cd #{ working_dir } && #{ command }`
    if $?.success?
      message.react("✅")
    else
      Log.error(output)
      raise DeployError, ":warning: Quack! Error with `#{ command }`!"
    end
  end
end
