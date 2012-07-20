require File.dirname(__FILE__) + '/../test_case'

module Halb
  class DeployTest < Test::Unit::TestCase
    def setup
      @active_lb=FakeLoadBalancer.new(true)
      load_balancers=[@active_lb, FakeLoadBalancer.new(false)]
      all_machines = {'machine1' => '10.1.0.111', 'machine2' => '10.1.0.222'}
      Socket.stubs(:gethostname).returns('machine1')
      @deploy=Deploy.with(load_balancers, all_machines)
    end

    def test_remove_from_production
      @deploy.remove_from_production
      assert_equal '10.1.0.111', @active_lb.called_with[:put_in_maintenance]
    end

    def test_put_into_production
      @deploy.put_into_production
      assert_equal '10.1.0.111', @active_lb.called_with[:remove_from_maintenance]
    end
  end

  class FakeLoadBalancer
    attr_reader :called_with

    def initialize(active)
      @active=active
      @called_with={}
    end

    def active?
      @active
    end

    def put_in_maintenance(host_to_put)
      @called_with[:put_in_maintenance] = host_to_put
    end

    def remove_from_maintenance(host_to_put)
      @called_with[:remove_from_maintenance] = host_to_put
    end
  end
end