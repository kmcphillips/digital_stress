# frozen_string_literal: true
class DeployCommand < BaseCommand
  class DeployError < StandardError ; end

  DEPLOY_APPS = {
    "kmcphillips/quigital" => {
      aliases: ["quigital"]
    },
    "kmcphillips/quigital_infohub" => {
      aliases: ["quigital_infohub", "infohub", "quigital.infohub"]
    },
    "kmcphillips/mandate.industries" => {
      aliases: ["mandate", "mandate.industries", "mandate_industries", "brochure"]
    },
    "kmcphillips/quigital_smarthome" => {
      aliases: ["quigital_smarthome", "smarthome", "homecomfort", "home_comfort", "home_comfort_advisor"]
    },

  }.freeze

  def response
    if params.count == 0
      "Quack! What should I deploy?"
    elsif params.count > 1
      "Quack! Just deploy one thing."
    else
      deploy_app_param = params.first.downcase
      deploy_app_name, _config = DEPLOY_APPS.find { |name, conf|
        deploy_app_param == name || (conf[:aliases] || []).include?(deploy_app_param)
      }

      if deploy_app_name
        deploy(deploy_app_name)
      else
        "Quack! Don't know how to deploy that."
      end
    end
  end

  def channels
    [
      "mandatemandate#general",
      "mandatemandate#quigital",
      "mandatemandate#websites",
      "duck-bot-test#testing",
    ].freeze
  end

  private

  def deploy(app)
    working_dir = "#{ base_working_dir }/#{ app }"

    @event.respond(":rocket: Deploying **#{ app }**")

    begin
      Bundler.with_clean_env do
        run_command("git pull", working_dir: working_dir)
        run_command("bundle install", working_dir: working_dir)
        if File.exists?("#{ working_dir }/spec")
          if !File.exists?("#{ working_dir }/config/credentials/test.key")
            `ln -s #{ base_working_dir }/shared/#{ app }/test.key #{ working_dir }/config/credentials/test.key`
          end
          run_command("RSPEC_SUPPRESS_PENDING=true bundle exec rspec", working_dir: working_dir, description: "Running test suite", on_error: ->(event, command, output) {
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
      Global.logger.error(output)
      on_error.call(@event, command, output) if on_error
      raise DeployError, ":warning: Quack! Error with #{ description }!"
    end
  end

  def base_working_dir
    @base_working_dir ||= Global.config.deploy_command.base_working_dir
    raise "`deploy_command.base_working_dir` is blank" unless @base_working_dir.present?
    @base_working_dir
  end
end
