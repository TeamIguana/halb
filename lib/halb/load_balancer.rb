module Halb
  class LoadBalancer < AbstractLoadBalancer
    def show_active_hosts_command
      'ipvsadm -l -n'
    end

    def active?
      !/TCP[ ]+\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/.match(get_output_of(show_active_hosts_command)).nil?
    end

    def in_maintenance_command(service_endpoint)
      "touch /etc/ha.d/maintenance/#{service_endpoint}"
    end

    def out_of_maintenance_command(service_endpoint)
      "rm /etc/ha.d/maintenance/#{service_endpoint}"
    end

    def service_endpoint_for(ip_address)
      "#{ip_address}:80"
    end
  end
end