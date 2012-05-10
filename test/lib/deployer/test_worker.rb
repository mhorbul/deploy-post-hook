require File.join(File.dirname(__FILE__), '../../test_helper')

class Deployer::TestWorker < MiniTest::Unit::TestCase
  def setup
    @config_gh_master = { "github" => { "branch" => "master", "home" => Deployer.root } }
    @config_gh_stage = { "github" => { "branch" => "stage", "home" => "/u/apps/github" } }
    @config_prj_one_master = { "project_one" => { "branch" => "master", "home" => "/u/apps/project_one" } }
    @json = File.read(File.join(Deployer.root, 'test/fixtures/payload.json'))
  end

  def test_process_configured_project
    worker = Deployer::Worker.new(:projects => @config_gh_master)
    assert_send([worker, :process, @json])
  end

  def test_not_process_configured_project_when_branch_does_not_match
    worker = Deployer::Worker.new(:projects => @config_gh_stage)
    worker.process(@json)
  end

  def test_not_process_project_when_not_configured
    worker = Deployer::Worker.new(:projects => @config_prj_one_master)
    worker.process(@json)
  end
end
