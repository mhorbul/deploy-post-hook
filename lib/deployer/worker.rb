require 'logger'
require 'yajl/json_gem'

module Deployer
  class Worker

    class ValidationError < Exception; end

    # @param [Hash] confg the config options to creat worker.
    # @option config [Logger] :logger The logger
    # @option config [Hash] :projects The list of projects for monitoring
    def initialize(config = {})
      @logger = config[:logger]
      @projects = config[:projects] || {}
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def process(payload)
      payload = JSON.parse(payload)
      branch = payload["ref"].gsub(%r{refs/heads/}, "")
      name = payload["repository"]["name"]
      logger.info("Start processing deploy request: project:#{name}; branch:#{branch}")
      deploy(name, branch) if should_deploy?(name, branch)
      logger.debug("Finish processing deploy request: project:#{name}; branch:#{branch}")
    end

    private
    def should_deploy?(name, branch)
      project = @projects[name]
      if project.nil?
        logger.debug("Skip project '#{name}'")
        return false
      end
      if project["branch"] != branch
        logger.debug("Skip branch '#{branch}' for project '#{name}'. Monitored branch is '#{project["branch"]}'")
        return false
      end
      if project["home"].nil?
        logger.warn("Home is not defined for project '#{name}'.")
        return false
      end
      unless File.directory?(project["home"])
        logger.warn("Home folder '#{project["home"]}' for project '#{name}' does not exit.")
        return false
      end
      true
    end

    def deploy(name, branch)
      start = Time.now
      logger.info("Deploying project '#{name}'...")
      project = @projects[name]
      command = "cd #{project["home"]} && git pull origin/#{project["branch"]} && cap deploy"
      logger.debug("-- CMD: #{command} --")
      logger.debug("-- OUT: --")
      out = `#{command} 2>&1`
    end
  end
end
