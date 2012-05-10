require 'sinatra'

class Deployer::WebHandler < Sinatra::Base
  post "/" do
    EM.defer do
      worker = Deployer::Worker.new(:logger => logger, :projects => Deployer.projects)
      worker.process(params[:payload])
    end
  end
end
