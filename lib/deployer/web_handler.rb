require 'sinatra'

class Deployer::WebHandler < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  post "/" do
    EM.defer do
      worker = Deployer::Worker.new(:logger => logger, :projects => Deployer.projects)
      worker.process(params[:payload])
    end
  end
end
