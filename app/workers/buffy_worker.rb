require 'yaml'
require 'erb'
require 'faraday'

require_relative '../lib/defaults'
require_relative '../lib/github'
require_relative '../lib/templating'

class BuffyWorker
  include Sidekiq::Worker
  include GitHub
  include Templating

  def rack_environment
    ENV['RACK_ENV'] || "test"
  end

  def path
    "tmp/#{jid}"
  end

  def load_context_and_settings(config)
    @context = OpenStruct.new(
      issue_id: config[:issue_id],
      repo: config[:repo],
    )

    document = ERB.new(IO.read("../../config/settings-#{rack_environment}.yml")).result
    yaml = YAML.load(document)
    buffy_settings = yaml[:buffy]

    @settings = {}
    @settings[:templates_path] = buffy_settings[:templates_path] || default_settings[:templates_path]
    @settings[:gh_access_token] = buffy_settings[:gh_access_token] || default_settings[:gh_access_token]
  end
end