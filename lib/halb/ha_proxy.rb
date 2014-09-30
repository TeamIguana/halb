module Halb
  class HAProxy < AbstractLoadBalancer
    def initialize(host, user, ssh_keys, cluster_ip, proxy_names)
      super(host, user, ssh_keys)
      @cluster_ip, @proxy_names = cluster_ip, proxy_names
    end

    def show_active_hosts_command
      proxy_names_expression = @proxy_names.join('|')
      "echo 'show stat -1' | socat stdio /tmp/haproxy.sock | grep -P '^(#{proxy_names_expression}),.*,UP'"
    end

    def active?
      get_output_of(@cluster_ip, 'hostname').strip == @host
    end

    def in_maintenance_command(machine)
      maintenance_command_for(machine, 'disable')
    end

    def out_of_maintenance_command(machine)
      maintenance_command_for(machine, 'enable')
    end

    def maintenance_command_for(machine, operation)
      commands = @proxy_names.map do |proxy_name|
        "#{operation} server #{proxy_name}/#{machine}"
      end
      "echo \"#{commands.join(' ; ')}\" | socat stdio /tmp/haproxy.sock"
    end

    def service_endpoint_for(machine)
      machine
    end
  end
end