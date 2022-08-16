#require "ruby_astm"
#require_relative 'lib/ruby_astm/astm_server'
require_relative 'lib/ruby_astm'
#require_relative "lib/ruby_astm/custom/cinzan_platform"


def test
	#For serial configuration.
	#serial_connections = [{port_address: '/dev/ttyACM0', baud_rate: 9600, parity: 8}]
	# Using ethernet configuration.
	ethernet_connections = [{:server_ip => "192.168.1.121", :server_port => 3000}]
	server = AstmServer.new(ethernet_connections,[])
	server.start_server
end


test





