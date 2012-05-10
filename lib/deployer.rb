module Deployer

  VERSION = "0.0.1"
  ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))

  autoload :WebHandler, "deployer/web_handler"
  autoload :Worker, "deployer/worker"

  def self.root; ROOT_PATH; end

end
