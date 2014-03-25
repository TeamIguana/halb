require File.dirname(__FILE__) + '/../test_case'

module Halb
  class HAProxyTest < Test::Unit::TestCase
    def setup
      @load_balancer=HAProxyWithFakeConnection.new
    end

    def test_remove_from_lb
      @load_balancer.output[HAProxy.show_active_hosts_command] = [still_in_balancer_response_for('host_to_remove_from_lb'), host_out_from_balancer_response]
      @load_balancer.expects(:sleep).once
      @load_balancer.put_in_maintenance('host_to_remove_from_lb')
      assert_equal 1, @load_balancer.call_count(/echo "disable server pxname1\/host_to_remove_from_lb ; disable server pxname2\/host_to_remove_from_lb" \| socat stdio \/tmp\/haproxy\.sock/)
      assert_equal 2, @load_balancer.call_count(HAProxy.show_active_hosts_command)
    end

    def test_put_in_lb
      @load_balancer.output[HAProxy.show_active_hosts_command] = [host_out_from_balancer_response, still_in_balancer_response_for('host_to_put_in_lb')]
      @load_balancer.expects(:sleep).once
      @load_balancer.remove_from_maintenance("host_to_put_in_lb")
      assert_equal 1, @load_balancer.call_count(/echo "enable server pxname1\/host_to_put_in_lb ; enable server pxname2\/host_to_put_in_lb" \| socat stdio \/tmp\/haproxy\.sock/)
      assert_equal 2, @load_balancer.call_count(HAProxy.show_active_hosts_command)
    end

    def test_not_active
      @load_balancer.output['hostname'] = ['other_host']
      assert_false @load_balancer.active?
      assert_equal '10.0.0.1', @load_balancer.last_connection_host
    end

    def test_active
      @load_balancer.output['hostname'] = ["fake_host\n"]
      assert_true @load_balancer.active?
      assert_equal '10.0.0.1', @load_balancer.last_connection_host
    end

    def still_in_balancer_response_for(host)
      "pxname1,#{host},0,0,0,1,,9,8341,5709,,0,,0,0,0,0,UP,1,1,0,3,0,316925,0,,1,3,2,,9,,2,0,,3,L7OK,200,38,0,3,6,0,0,0,0,,,,0,0,,,,,
              pxname1,server2,0,0,0,1,,9,8341,5709,,0,,0,0,0,0,UP,1,1,0,3,0,316925,0,,1,3,2,,9,,2,0,,3,L7OK,200,38,0,3,6,0,0,0,0,,,,0,0,,,,,
              pxname1,BACKEND,0,0,0,1,200,34,32123,14569,0,0,,0,0,0,0,UP,2,2,0,,0,316925,0,,1,3,0,,34,,1,0,,3,,,,0,5,29,0,0,0,,,,,0,0,0,0,0,0,
              pxname2,#{host},0,0,0,1,,82,83801,1082763,,0,,0,0,0,0,UP,1,1,0,15,0,316925,0,,1,4,2,,82,,2,0,,9,L7OK,200,657,0,59,19,4,0,0,0,,,,2,0,,,,,
              pxname2,server2,0,0,0,1,,82,83801,1082763,,0,,0,0,0,0,UP,1,1,0,15,0,316925,0,,1,4,2,,82,,2,0,,9,L7OK,200,657,0,59,19,4,0,0,0,,,,2,0,,,,,
              pxname2,BACKEND,0,0,0,4,200,196,201356,3970686,0,0,,0,0,0,0,UP,2,2,0,,0,316925,0,,1,4,0,,196,,1,0,,21,,,,0,144,46,6,0,0,,,,,4,0,0,0,0,0,"
    end

    def host_out_from_balancer_response
      'pxname1,server2,0,0,0,1,,9,8341,5709,,0,,0,0,0,0,UP,1,1,0,3,0,316925,0,,1,3,2,,9,,2,0,,3,L7OK,200,38,0,3,6,0,0,0,0,,,,0,0,,,,,
              pxname1,BACKEND,0,0,0,1,200,34,32123,14569,0,0,,0,0,0,0,UP,2,2,0,,0,316925,0,,1,3,0,,34,,1,0,,3,,,,0,5,29,0,0,0,,,,,0,0,0,0,0,0,
              pxname2,server2,0,0,0,1,,82,83801,1082763,,0,,0,0,0,0,UP,1,1,0,15,0,316925,0,,1,4,2,,82,,2,0,,9,L7OK,200,657,0,59,19,4,0,0,0,,,,2,0,,,,,
              pxname2,BACKEND,0,0,0,4,200,196,201356,3970686,0,0,,0,0,0,0,UP,2,2,0,,0,316925,0,,1,4,0,,196,,1,0,,21,,,,0,144,46,6,0,0,,,,,4,0,0,0,0,0,'
    end
  end

  class HAProxyWithFakeConnection < HAProxy
    include FakeConnectionModule

    def initialize
      super('fake_host', 'a_user', ['ssh_key'], '10.0.0.1', ['pxname1','pxname2'])
    end
  end
end