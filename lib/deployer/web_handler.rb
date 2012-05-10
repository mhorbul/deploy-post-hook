class Deployer::WebHandler < Sinatra::Base
  get "/" do
    EM.defer do
      worker = Deployer::Worker.new(logger)
      worker.process(params[:payload])
    end
  end
end
