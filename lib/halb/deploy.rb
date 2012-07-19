require 'socket'

module Halb
  class Deploy
    def initialize(load_balancers, machines)
      @load_balancers=load_balancers
      @this_computer=Socket.gethostname.downcase
      @machines = machines
    end

    def active_balancer
      @load_balancers.detect { |lb| lb.active? }
    end

    def remove_from_production
      active_balancer.put_in_maintenance(@machines[@this_computer])
    end

    def put_into_production
      active_balancer.remove_from_maintenance(@machines[@this_computer])
    end
  end
end