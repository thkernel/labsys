class Result
	attr_accessor :name
	attr_accessor :report_name
	attr_accessor :value
	attr_accessor :units
	attr_accessor :flags
	attr_accessor :timestamp
	attr_accessor :reference_ranges
	attr_accessor :dilution
	## array.
	attr_accessor :alternate_lis_codes

	## sometimes we customize the lis code based on the machine which is sending it, so we need this.
	attr_accessor :machine_name

	def set_name(args)
		puts "came to set name"
		if line = args[:line]
			puts "line fields is: #{line.fields}"
			unless line.fields[2].blank?
				puts "line fields 2 is:"
				puts line.fields[2]
				line.fields[2].scan(/^\^+(?<name>[A-Za-z0-9\%\#\-\_\?\/]+)\^?(?<dilution>\d+)?/) { |name,dilution|  
					
					self.name = lookup_mapping(name)

					## other names.
					
					self.report_name = lookup_report_name(name)

				}
			end

			unless self.name.blank?
				self.name.scan(/(?<test_name>\d+)\/(?<dilution>\d+)\/(?<pre_dilution>[a-zA-Z0-9]+)/) { |test_name,dilution,pre_dilution|

					self.name = lookup_mapping(test_name)

					self.report_name = lookup_report_name(test_name)

					self.dilution = dilution

				}
			end


		end
	end

	def set_value(args)
		if line = args[:line]

			unless line.fields[3].blank?
				self.value = line.fields[3].strip
				self.value.scan(/(?<flag>\d+)\^(?<value>\d?\.?\d+)/) {|flag,value|
					self.value = value
				}
			end
			unless line.fields[2].blank?
				puts "line fields 2 is:"
				puts line.fields[2]
				puts "----------------------------"
				line.fields[2].scan(/\^+(?<name>[A-Za-z0-9\%\#\-\_\?\/]+)\^?(?<dilution>\d+)?/) { |name,dilution|  
					if transform_expression = lookup_transform(name)
						self.value = eval(transform_expression)
					end
				}
			end

		end
	end

	def set_flags(args)
		if line = args[:line]

			unless line.fields[6].blank?
				self.flags = line.fields[6].strip
			end

		end 
	end	

	def set_units(args)

	end

	def set_timestamp(args)
		if line = args[:line]
			unless line.fields[12].blank?
				line.fields[12].strip.scan(/(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})/) {|year,month,day,hours,minutes,seconds|
					self.timestamp = Time.new(year,month,day,hours,minutes,seconds)
				}
			end
		end
	end

	def set_reference_ranges(args)
		if line = args[:line]

			unless line.fields[5].blank?
				self.reference_ranges = line.fields[5].strip
			end

		end
	end

	def set_dilution(args)
		if line = args[:line]

			unless line.fields[2].blank?
				line.fields[2].scan(/\^+(?<name>[A-Za-z0-9\%\#\-\_\?\/]+)\^?(?<dilution>\d+)?/) { |name,dilution|  
					self.dilution = dilution unless self.dilution
				}
			end

		end
	end

	def set_machine_name(args)
		self.machine_name = args[:machine_name]
	end

	## item validation has to be done.
	## and only if it has been outsourced.
	## and mask the patient name.

	def all_lis_codes 
		self.alternate_lis_codes + [self.name]
	end

	## here will call mappings and check the result correlation
	def initialize(args={})
		#puts "called initialize result"
		self.alternate_lis_codes ||= []
		set_name(args)
		set_flags(args)
		set_value(args)
		#set_timestamp(args) by me
		set_dilution(args)
		set_units(args)


=begin
		if args[:line]
			line = args[:line]
			transform_expression = nil
			line.fields[2].scan(/\^+(?<name>[A-Za-z0-9\%\#\-\_\?\/]+)\^?(?<dilution>\d+)?/) { |name,dilution|  
				self.name = lookup_mapping(name)
				self.dilution = dilution
				transform_expression = lookup_transform(name)
			}
			self.value = line.fields[3].strip
			if transform_expression
				self.value = eval(transform_expression)
			end
			self.reference_ranges = line.fields[5].strip
			self.flags = line.fields[6].strip 
			line.fields[12].strip.scan(/(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})/) {|year,month,day,hours,minutes,seconds|
				self.timestamp = Time.new(year,month,day,hours,minutes,seconds)
			}
		else
			super
		end
=end

	end

	## @return[String] the name defined in the mappings.json file, or the name that wqs passed in.
	def lookup_mapping(name)
		unless $mappings[name].blank?
			unless self.machine_name.blank?
				unless $mappings[name]["MACHINE_SPECIFIC_LIS_CODES"].blank?
					unless $mappings[name]["MACHINE_SPECIFIC_LIS_CODES"][self.machine_name].blank?
						redirect = $mappings[name]["MACHINE_SPECIFIC_LIS_CODES"][self.machine_name]
						unless $mappings[redirect].blank?
							$mappings[redirect]["LIS_CODE"]
						end
					end
				end		
			else
				$mappings[name]["LIS_CODE"]
			end
		else
			name
		end
		#$mappings[name] ? $mappings[name]["LIS_CODE"] : name 
	end

	## these mappings are defined, for the same machine code.
	def lookup_alternate_mappings(name)
		unless $mappings[name].blank?
			unless $mappings[name]["ALTERNATE_LIS_CODES"].blank?
				self.alternate_lis_codes = $mappings[name]["ALTERNATE_LIS_CODES"]
			end
		end
	end

	def lookup_transform(name)
		$mappings[name] ? $mappings[name]["TRANSFORM"] : nil
	end

	def lookup_report_name(name)
		$mappings[name] ? $mappings[name]["REPORT_NAME"] : name
	end

end