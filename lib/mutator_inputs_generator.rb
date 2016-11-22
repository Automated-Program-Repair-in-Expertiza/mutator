require 'yaml'
require_relative './method_finder.rb'
require_relative './string.rb'
require 'pry'

# TODO: solve relative path problem
#
# Generate the inputs of mutator
# use method_finder.rb to find the method block containing target line
# generate a new file only contains class declaration and this method block
#
parent_dir_path = File.expand_path("../../../", __FILE__)
fault_locations = YAML.load_file("#{parent_dir_path}/mutator/results/fault-localization.yml")
method_finder = nil

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	file_path = content['File']
	num_of_line = content['LineNum']

	full_file_path = "#{parent_dir_path}/expertiza/#{file_path}"
	method_finder = MethodFinder.new(full_file_path)
	first_line = ''
	class_name = ''
	File.readlines(full_file_path).each do |line|
		# find the class declaration line of origin file to
		# become the first line of new file
		if line.start_with? 'class'
			first_line = line 
			class_name = line.match(/\s[a-zA-Z]+\s/).to_s.strip.underscore
			break
		end
	end

	method_block = method_finder.find(num_of_line)
	directory_path = "#{parent_dir_path}/mutator/results/mutator-inputs/#{airbrake_group_id}"
	Dir.mkdir(directory_path) unless File.exists?(directory_path)
	mutator_input_file_path = "#{directory_path}/#{class_name}.rb"
	file = File.open(mutator_input_file_path, 'w+')
	file.puts(first_line)
	file.puts('  ' + method_block)
	file.puts('end')
	file.close
	puts "Mutator-inputs #{class_name}.rb is generated!"
end