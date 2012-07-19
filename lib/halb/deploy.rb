require 'socket'

module Halb
  class Deploy
    def initialize(load_balancers, machine)
      @load_balancers=load_balancers
      @machine = machine
    end

    def self.with(load_balancers, machines)
      this_machine = machines[Socket.gethostname.downcase]
      new(load_balancers, this_machine)
    end

    def active_balancer
      @load_balancers.detect { |lb| lb.active? }
    end

    def remove_from_production
      active_balancer.put_in_maintenance(@machine)
    end

    def put_into_production
      active_balancer.remove_from_maintenance(@machine)
    end
  end
end