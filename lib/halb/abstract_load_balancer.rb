require 'net/ssh'

module Halb
  class AbstractLoadBalancer
    def initialize(fqdn, user, ssh_keys)
      @fqdn, @user, @ssh_keys = fqdn, user, ssh_keys
    end

    def get_output_of(fqdn=@fqdn, command)
      output=''
      open_connection(fqdn) do |ssh|
        output=ssh.exec!(command)
      end
      output
    end

    def put_in_maintenance(machine)
      service_endpoint=service_endpoint_for(machine)
      perform(:command => in_maintenance_command(service_endpoint),
              :exit_when => lambda { |ssh| !ssh.exec!(show_active_hosts_command).to_s.include?(service_endpoint) })
    end

    def remove_from_maintenance(host)
      service_endpoint = service_endpoint_for(host)
      perform(:command => out_of_maintenance_command(service_endpoint),
              :exit_when => lambda { |ssh| ssh.exec!(show_active_hosts_command).to_s.include?(service_endpoint) })
    end

    def perform(params)
      open_connection do |ssh|
        ssh.exec!(params[:command])
        loop do
          break if params[:exit_when].call(ssh)
          sleep(1)
        end
      end
    end

    def open_connection(fqdn=@fqdn, &block)
      Net::SSH.start(fqdn, @user, :keys => @ssh_keys, &block)
    end
  end
end