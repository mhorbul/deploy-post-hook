require 'sinatra'

class Deployer::WebHandler < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  post "/" do
    worker.enqueue(params[:payload])
  end

  def deferred?(env)
    logger.info("env: #{env.inspect}")
    true
  end

  private
  def worker
    logger.level = Logger::DEBUG
    @worker ||= Deployer::Worker.new(:logger => logger, :projects => Deployer.projects)
  end
end
