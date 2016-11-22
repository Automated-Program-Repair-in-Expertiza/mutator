require 'yaml'
require_relative './method_finder.rb'
require 'pry'

# TODO: solve relative path problem
parent_dir_path = File.expand_path("../../../", __FILE__)
fault_locations = YAML.load_file(parent_dir_path + '/mutator/results/fault-localization.yml')
method_finder = nil

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	file_path = content['File']
	num_of_line = content['LineNum']

	full_file_path = parent_dir_path + '/expertiza/' + file_path
	method_finder = MethodFinder.new(full_file_path)
	first_line = ''
	File.readlines(full_file_path).each do |line|
		# find the class declaration line of origin file to
		# become the first line of new file
		if line.start_with? 'class'
			first_line = line 
			break
		end
	end

	method_block = method_finder.find(num_of_line)
	mutator_input_file_path = parent_dir_path + '/mutator/results/mutator-inputs/' + airbrake_group_id.to_s + '.rb'
	file = File.open(mutator_input_file_path, 'w+')
	file.puts(first_line)
	file.puts('  ' + method_block)
	file.puts('end')
	file.close
	puts "Mutator-inputs #{airbrake_group_id}.rb is generated!"
end