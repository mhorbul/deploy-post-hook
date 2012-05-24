# -*- coding: utf-8 -*-
require 'logger'
require 'yajl/json_gem'
require 'mixlib/shellout'

module Deployer
  class Worker

    class ValidationError < Exception; end

    # @param [Hash] confg the config options to creat worker.
    # @option config [Logger] :logger The logger
    # @option config [Hash] :projects The list of projects for monitoring
    def initialize(config = {})
      @logger = config[:logger]
      @projects = config[:projects] || {}
      @queue = EM::Queue.new
      EM.add_periodic_timer(2) { perform }
    end

    def enqueue(payload)
      payload = JSON.parse(payload)
      branch = payload["ref"].to_s.gsub(%r{refs/heads/}, "")
      name = payload["repository"]["name"]
      if should_deploy?(name, branch)
        logger.info("Enqueue deployment for #{name}/#{branch}")
        @queue.push name
      end
    end

    def perform(name)
      @queue.pop do |project_name|
        deploy(project_name)
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    private
    def should_deploy?(name, branch)
      project = @projects[name]
      if project.nil?
        logger.warn("Skip project '#{name}'")
        return false
      end
      if project["branch"] != branch
        logger.warn("Skip branch '#{branch}' for project '#{name}'. Monitored branch is '#{project["branch"]}'")
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

    def deploy(name)
      start = Time.now
      logger.info("Deploying project '#{name}'...")
      project = @projects[name]
      cmd = "cd #{project["home"]}/shared/cached-copy && git pull origin #{project["branch"]} && cap deploy"
      command = Mixlib::ShellOut.new(cmd, :cwd => project["home"], :logger => logger)
      command.run_command
      msg = command.format_for_exception
      logger.debug(msg)
#      result = `#{cmd}`
#      logger.debug(result)
    end
  end
end
