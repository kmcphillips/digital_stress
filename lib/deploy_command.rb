# frozen_string_literal: true
class DeployCommand < BaseCommand
  BASE_WORKING_DIR = "/home/deploy/apps/digital_stress/shared/deploy_from"
  CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#quigital",
    "duck-bot-test#testing",
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
    working_dir = "#{ BASE_WORKING_DIR }/#{ app }"

    @event.respond(":rocket: Deploying #{ app }")

    begin
      Bundler.with_clean_env do
        run_command("git pull", working_dir: working_dir)
        run_command("bundle install", working_dir: working_dir)
        if File.exists?("#{ working_dir }/spec")
          if !File.exists?("#{ working_dir }/config/credentials/test.key")
            `ln -s #{ BASE_WORKING_DIR }/shared/#{ app }/test.key #{ working_dir }/config/credentials/test.key`
          end
          run_command("bundle exec rspec", working_dir: working_dir, description: "Running test suite", on_error: ->(event, command, output) {
            msg = (output.split("Failures:\n").last || "").truncate(1980, omission: "")
            event.respond("```\n#{ msg }\n```") if msg.present?
          })
        end
        run_command("bundle exec cap production deploy", working_dir: working_dir, on_error: ->(event, command, output) {
            msg = (output || "").reverse.truncate(1200, omission: "").reverse
            event.respond("```\n#{ msg }\n```") if msg.present?
          })
      end
    rescue DeployError => e
      return e.message
    end

    ":tada: Quack! Deploy complete."
  end

  def run_command(command, working_dir:, description: nil, on_error: nil)
    description = description.presence || "`#{ command }`"
    message = @event.respond(description)
    output = `cd #{ working_dir } && #{ command }`
    if $?.success?
      message.react("✅")
    else
      Log.error(output)
      on_error.call(@event, command, output) if on_error
      raise DeployError, ":warning: Quack! Error with #{ description }!"
    end
  end
end
