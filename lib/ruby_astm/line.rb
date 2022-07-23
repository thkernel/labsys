class Line

	TYPES = {
		"H" => "Header",
		"MSH" => "Hl7_Header",
		"OBX" => "Hl7_Observation",
		"PID" => "Hl7_Patient",
		"OBR" => "Hl7_Order",
		"P" => "Patient",
		"Q" => "Query",
		"O" => "Order",
		"R" => "Result",
		"L" => "Terminator"
	}

	attr_accessor :text
	
	attr_accessor :fields
	
	attr_accessor :type

	########################################################
	##
	##
	## HEADER ATTRIBUTES
	##
	##
	########################################################

	## sets the types, and fields
	## we can have processing based on line.
	def initialize(args)
		puts "INITIALIZING..."
		self.fields = []
		raise "no text provided" unless args[:text]
		if args[:text]
			puts "ARGS: YES"
			args[:text].split(/\|/).each do |field|
				self.fields << field
			end
		end

		puts "FIELDS IN INITIALIZE: #{self.fields}"
		detect_type
	end 

	def detect_type
		puts "BEFORE LINE TYPE DETECT"
		#puts "detecting line type: #{self.text}"
		line_type = self.fields[0]
		#puts "FIELDS: #{self.fields}"
		puts "LINE TYPE: #{line_type}"
		return unless line_type
		line_type.scan(/(?<ltype>[A-Z]+)/) { |ltype| 
			if Line::TYPES[ltype[0]]
				self.type = Line::TYPES[ltype[0]]
			end
		}

		puts "LINE TYPE DETECTED: #{self.type}"	

		puts "============================================================================="	

	end

	

end