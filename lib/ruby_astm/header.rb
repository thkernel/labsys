class Header
	attr_accessor :machine_name
	attr_accessor :patients
	attr_accessor :queries
	attr_accessor :response_sent
	attr_accessor :protocol

	def is_astm?
		self.protocol == "ASTM"
	end		

	def is_hl7?
		self.protocol == "HL7"
	end


	def set_protocol(args)
		self.protocol = "ASTM"
	end	

	def initialize(args={})
		self.patients = []
		self.queries = []
		self.response_sent = false
		if line = args[:line]
			set_machine_name(args)
			set_protocol(args)
		end
	end

	def set_machine_name(args)
		if line = args[:line]
			unless line.fields[4].empty?
				fields = line.fields[4].split(/\^/)
				self.machine_name = fields[0].strip
			end
		end
	end

	## pushes each patient into a redis list called "patients"
	def commit
		#self.patients.map{|patient| $redis.lpush("patients",patient.to_json)}
		puts JSON.pretty_generate(JSON.parse(self.to_json))

		puts "COMMITED"
	end

	def get_header_response(options)
		if (options[:machine_name] && (options[:machine_name] == "cobas-e411"))
			"1H|\\^&|||host^1|||||cobas-e411|TSDWN^REPLY|P|1\r"
		else
			"1H|\`^&||||||||||P|E 1394-97|#{Time.now.strftime("%Y%m%d%H%M%S")}\r"
		end
	end

	## depends on the machine code.
	## if we have that or not.
	def build_one_response(options)
		puts "building one response=========="
		puts "queries are:"
		puts self.queries.size.to_s
		responses = []
		self.queries.each do |query|
			puts "doing query"
			puts query.sample_ids
			header_response = get_header_response(options)
			query.build_response(options).each do |qresponse|
				puts "qresponse is:"
				puts qresponse
				header_response += qresponse
			end
			responses << header_response
		end
		responses
	end

	## used to respond to queries.
	## @return[String] response_to_query : response to the header query.
	def build_responses
		responses = []
		self.queries.each do |query|
			header_response = "1H|\`^&||||||||||P|E 1394-97|#{Time.now.strftime("%Y%m%d%H%M%S")}\r"
			query.build_response.each do |qresponse|
				responses << (header_response + qresponse)
			end
		end
=begin
		responses = self.queries.map {|query|
			header_response = "1H|\`^&||||||||||P|E 1394-97|#{Time.now.strftime("%Y%m%d%H%M%S")}\r"
			## here the queries have multiple responses.
			query.build_response.each do |qresponse|

			end
			query.response = header_response + query.build_response
			query.response
		}
=end
		responses
	end

	def to_json(args={})
        hash = {}
        puts "INSTANCE VARIABLES: #{self.instance_variables}"
        instance_var ||= File.join root,'../poly_test',"instance#{Time.now}.txt"
        jsonf ||= File.join root,'../poly_test',"jsonf#{Time.now}.json"

        IO.write(instance_var, self.instance_variables )
        self.instance_variables.each do |x|
            hash[x] = self.instance_variable_get x
            puts "CURRENT INSTANCE VAR: #{hash[x]}"
            current_instance_var ||= File.join root,'../poly_test',"#{x}_instance#{Time.now}.txt"
            IO.write(current_instance_var, self.instance_variable_get(x) )
        end
        IO.write(jsonf, hash.to_json )

        # Process and send results to SIH
        process_results(JSON.parse(hash.to_json))
        return hash.to_json
    end

    #By me

    ## returns the root directory of the gem.
  def root
      File.dirname __dir__
  end


  def process_results(results)
  	

  	
  	puts "RESULT IN JSON: #{results}"

	token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MjY0Mzk2NzcsImlzcyI6Imh0dHA6XC9cLzE5Mi4xNjguMTAwLjEwMFwvc2loX2hkYlwvYXBwXC9hcGlcLyIsImRhdGEiOnsiaWQiOiIxNTIiLCJmaXJzdG5hbWUiOiJDZXJ0ZXNfbGFibyIsImxhc3RuYW1lIjoiQ2VydGVzIiwibG9naW4iOiJjX2FkbWluIiwicGVybWlzc2lvbiI6InZpZXcubGFibyxsYWJfcGFyYW1ldHJhZ2UucmVzaCxsYWJfdHlwZV9hbmFseXNlLmxpc3RlLnJlc2gsbGFiX2FuYWx5c2UubGlzdGUucmVzaCxsYWJfcHJvdmVuYW5jZS5saXN0ZS5yZXNoIn19.gzMsLUfeHPPpRXfsA0tCofu4vAIl6btB0gnEoMvYooI"
	bench_number = nil
	new_results_hash = Hash.new

	patients = results["@patients"]
	puts "ORDERS: #{patients}"

	patients.each do |patient|
		#puts "PATIENT: #{patient}"
		orders = patient["orders"]
		
		puts "ORDERS: #{orders}"

		orders.each do  |order|
			bench_number = order["id"]

			results = order["results"]
			key = results.keys[0]
			analyse = results.values[0]
			puts "RESULTS KEY: #{key}"
			puts "RESULTS VALUE: #{analyse}"
			new_results_hash[key] = {value: analyse["value"], um: analyse["units"]}
		end

	end

	final_results_hash = Hash.new 
	final_results_hash["token"] = token
	final_results_hash["bench_number"] = bench_number
	final_results_hash["automate_name"] = ""
    final_results_hash["automate_ip"] =  ""
	final_results_hash["analyzes"] = new_results_hash
	puts "NEW RESULTS HASH: #{final_results_hash}"
	
	puts "NEW RESULTS HASH TO: #{final_results_hash.to_json}"
	# Send data to SIH
	send_results(final_results_hash)
	

end

	def send_results(results)
		#uri = "http://apps.certesmali.org/sih/app/api/labo/save/" online api
		uri = URI('http://192.168.1.11/pg_test/app/api/labo/save/') #local
		puts "URI: #{uri}"
	    http = Net::HTTP.new(uri.host, uri.port)
	    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
	    puts "RESULTS BEFORE SEND: #{results.to_json}"
	    req.body = results.to_json
	    res = http.request(req)
	    puts "response #{res.body}"

	rescue => e
	    puts "failed #{e}"
	end


	# Get analyses by bench_number
	def get_analyses_by_bench_number(bench_number)

		token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MjY0Mzk2NzcsImlzcyI6Imh0dHA6XC9cLzE5Mi4xNjguMTAwLjEwMFwvc2loX2hkYlwvYXBwXC9hcGlcLyIsImRhdGEiOnsiaWQiOiIxNTIiLCJmaXJzdG5hbWUiOiJDZXJ0ZXNfbGFibyIsImxhc3RuYW1lIjoiQ2VydGVzIiwibG9naW4iOiJjX2FkbWluIiwicGVybWlzc2lvbiI6InZpZXcubGFibyxsYWJfcGFyYW1ldHJhZ2UucmVzaCxsYWJfdHlwZV9hbmFseXNlLmxpc3RlLnJlc2gsbGFiX2FuYWx5c2UubGlzdGUucmVzaCxsYWJfcHJvdmVuYW5jZS5saXN0ZS5yZXNoIn19.gzMsLUfeHPPpRXfsA0tCofu4vAIl6btB0gnEoMvYooI"

		uri = URI("http://192.168.1.11/app/api/labo/")
		params = { :token => token, :pallaisse => bench_number}
		uri.query = URI.encode_www_form(params)

		res = Net::HTTP.get_response(uri)
		puts res.body if res.is_a?(Net::HTTPSuccess)

	rescue => e
	    puts "failed #{e}"
	end

end