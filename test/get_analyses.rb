require 'net/http'
require "json"

def get_analyses_by_bench_number(bench_number)

		token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2Mjc1NjIxNjYsImlzcyI6Imh0dHA6XC9cLzE5Mi4xNjguMTAwLjEwMFwvc2loX2hkYlwvYXBwXC9hcGlcLyIsImRhdGEiOnsiaWQiOiIxIiwiZmlyc3RuYW1lIjoiQURNSU4iLCJsYXN0bmFtZSI6IkFkbWluIiwibG9naW4iOiJhZG1pbiIsInBlcm1pc3Npb24iOiIifX0.wLeZ2WJVAg9tkiW7jkDXY2wceOUSTc8jza2bdyks0qw"

		#uri = URI("http://apps.certesmali.org/sih/app/api/labo/")
		#params = { :token => token, :pallaisse => bench_number}
		#uri.query = URI.encode_www_form(params)

		#res = Net::HTTP.post_response(uri)
		#puts res.body if res.is_a?(Net::HTTPSuccess)


		uri = URI('http://apps.certesmali.org/sih/app/api/labo/') # local
		puts "URI: #{uri}"
	    http = Net::HTTP.new(uri.host, uri.port)
	    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')

	    payload = Hash.new
	    payload["token"] = token
	    payload["pallaisse"] = bench_number

	    puts "TO JSON: #{payload.to_json}"
	   
	    req.body = payload.to_json
	    res = http.request(req)


	    puts "response #{res.body}"
	    

	rescue => e
	    puts "failed #{e}"
	end



	get_analyses_by_bench_number("1-23112020")

	