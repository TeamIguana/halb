require 'net/ssh'

module Halb
  class LoadBalancer
    SHOW_ACTIVE_HOSTS_COMMAND='ipvsadm -l -n'

    def initialize(host, user, ssh_keys)
      @host, @user, @ssh_keys = host, user, ssh_keys
    end

    def active?
      !/TCP[ ]+\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/.match(get_output_of(SHOW_ACTIVE_HOSTS_COMMAND)).nil?
    end

    def get_output_of(command)
      output=''
      open_connection do |ssh|
        output=ssh.exec!(command)
      end
      output
    end

    def put_in_maintenance(ip_address)
      service_endpoint=service_endpoint_for(ip_address)
      perform(:command => "touch /etc/ha.d/maintenance/#{service_endpoint}", :exit_when => lambda { |ssh| !ssh.exec!(SHOW_ACTIVE_HOSTS_COMMAND).include?(service_endpoint) })
    end

    def remove_from_maintenance(ip_address)
      service_endpoint = service_endpoint_for(ip_address)
      perform(:command => "rm /etc/ha.d/maintenance/#{service_endpoint}", :exit_when => lambda { |ssh| ssh.exec!(SHOW_ACTIVE_HOSTS_COMMAND).include?(service_endpoint) })
    end

    def service_endpoint_for(ip_address)
      "#{ip_address}:80"
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

    def open_connection(&block)
      Net::SSH.start(@host, 'root', :keys => @ssh_keys, &block)
    end
  end
end