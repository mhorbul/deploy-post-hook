require 'rubygems'
require 'bundler'
Bundler.setup

require File.expand_path(File.join(File.dirname(__FILE__), 'lib/deployer'))
$:.push File.join(Deployer.root, "lib")
