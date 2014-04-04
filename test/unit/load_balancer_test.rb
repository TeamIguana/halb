require File.dirname(__FILE__) + '/../test_case'

module Halb
  class LoadBalancerTest < Test::Unit::TestCase
    def setup
      @load_balancer=LoadBalancerWithFakeConnection.new
    end

    def test_put_in_maintenance
      assert_equal 'ipvsadm -l -n', @load_balancer.show_active_hosts_command
      @load_balancer.output[@load_balancer.show_active_hosts_command] = ['output of ipvsadm says: ip_to_remove:80 is still there', 'ip_to_remove:81 up']
      @load_balancer.expects(:sleep).once
      @load_balancer.put_in_maintenance("ip_to_remove")
      assert_equal 1, @load_balancer.call_count(/touch (.*)ip_to_remove:80/)
      assert_equal 2, @load_balancer.call_count(@load_balancer.show_active_hosts_command)
    end

    def test_remove_from_maintenance
      @load_balancer.output[@load_balancer.show_active_hosts_command] = ['ip_to_insert:81 is here', 'output of ipvsadm says: ip_to_insert:80 now is there']
      @load_balancer.expects(:sleep).once
      @load_balancer.remove_from_maintenance("ip_to_insert")
      assert_equal 1, @load_balancer.call_count(/rm (.*)ip_to_insert:80/)
      assert_equal 2, @load_balancer.call_count(@load_balancer.show_active_hosts_command)
    end

    def test_ssh_connection
      Net::SSH.expects(:start).with do |host, user, keys, &block|
              assert_equal('fake_host', host)
              assert_equal('a_user', user)
              assert_equal({keys: ['ssh_key']}, keys)
              true
            end
      real_load_balancer = LoadBalancer.new('fake_host', 'a_user', ['ssh_key'])
      real_load_balancer.open_connection{}
    end

    def test_not_active
      output = 'IP Virtual Server version 1.2.1 (size=4096)'
      @load_balancer.output[@load_balancer.show_active_hosts_command] = [output]
      assert_false @load_balancer.active?
    end

    def test_active
      output = <<-EOF
    IP Virtual Server version 1.2.1 (size=4096)
    TCP  10.1.0.50:80 sh
      EOF
      @load_balancer.output[@load_balancer.show_active_hosts_command] = [output]
      assert_true @load_balancer.active?
    end
  end

  class LoadBalancerWithFakeConnection < LoadBalancer
    include FakeConnectionModule

    def initialize
      super('fake_host', 'a_user', ['ssh_key'])
    end
  end
end