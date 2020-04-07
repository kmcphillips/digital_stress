# frozen_string_literal: true
class DeployCommand < BaseCommand
  BASE_WORKING_DIR = "/home/deploy/apps/digital_stress/shared/deploy_from"
  CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#quigital",
    "duck-bot-test#general",
  ].freeze

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

    `cd #{ working_dir } && git pull`
    if $?.success?
      @event.respond(":white_check_mark: `git pull`")
    else
      return ":warning: Quack! Error with `git pull`!"
    end

    `cd #{ working_dir } && bundle install`
    if $?.success?
      @event.respond(":white_check_mark: `bundle install`")
    else
      return ":warning: Quack! Error with `bundle install`!"
    end

    `cd #{ working_dir } && bundle exec cap production deploy`
    if $?.success?
      @event.respond(":white_check_mark: `bundle exec cap production deploy`")
    else
      return ":warning: Quack! Error with `bundle exec cap production deploy`!"
    end

    "Quack! Deploy complete."
  end
end
