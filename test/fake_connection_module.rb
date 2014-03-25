module Halb
  module FakeConnectionModule
    attr_accessor :output
    attr_accessor :last_connection_host

    def initialize(*args)
      @commands=[]
      @output={}
      super
    end

    def open_connection(host=nil, &block)
      @last_connection_host = host
      block.call(self)
      nil
    end

    def call_count(command_regex)
      @commands.select { |c| c.match(command_regex) }.count
    end

    def exec!(command)
      @commands << command
      if @output.has_key?(command)
        @output[command] = @output[command].reverse
        @output[command].pop
      end
    end
  end
end