require 'net/http'
require 'uri'
require 'json'

class CinzanPlatform
	attr_accessor :host
	attr_accessor :api_base
    attr_accessor :host_port
    attr_accessor :token


    def initialize(host, host_port, api_base, token)
    	@host = host
    	@host_port = host_port
    	@api_base = api_base
    	@token = token

    end

	def postt_data(data)

		# Payload
		payload = {
			:token => "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTI4NzAyMDQsImlzcyI6Imh0dHA6XC9cLzE5Mi4xNjguMTAwLjEwMFwvc2loX2hkYlwvYXBwXC9hcGlcLyIsImRhdGEiOnsiaWQiOiIxIn19.DeaAPNjt4VicQ7-dU8WN6nfqKu22oKte6X7zwPQIC0c",
			:data => data
		}

		# Prepare URL
		url = "http://#{@host}:#{@host_port}#{@api_base}"
		uri = URI.parse(url)

		# Prepare header.
		header = {
			"Content-Type" => "application/json",
			
		}

		#"Authorization" => "Bearer #{@token}"


		# Create the HTTP objects
		http = Net::HTTP.new(uri.host, uri.port)

		#Set token on body
		token = ""
		request = Net::HTTP::Post.new(uri.request_uri, header)
		request.body = payload.to_json

		# Send the request
		response = http.request(request)

		puts "RESPONSE: #{response}"

	end

end