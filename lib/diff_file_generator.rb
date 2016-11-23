require 'yaml'
require_relative './string.rb'

parent_dir_path = File.expand_path("../../../", __FILE__)
fault_locations = YAML.load_file("#{parent_dir_path}/mutator/results/fault-localization.yml")

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	# TODO: separate path variable into common YAML file
	output_file_path = "#{parent_dir_path}/mutator/results/mutator-outputs/#{airbrake_group_id}"
	directory_path = "#{parent_dir_path}/mutator/results/mutator-splitted-new-methods/#{airbrake_group_id}"

	iterator = 1
	mutator_method = ''
	add_line_into_mutator_method = false
	puts "Separate mutators for #{airbrake_group_id}"

	File.readlines(output_file_path).each do |line|
		if line.start_with? ' def'
			mutator_method += (' ' + line)
			add_line_into_mutator_method = true
		end

		if line.start_with? '--'
			Dir.mkdir(directory_path) unless Dir.exists?(directory_path)
			full_file_path = "#{parent_dir_path}/expertiza/#{source_file_path}"

			puts "mutator_#{iterator}"
			mutator_diff_path = "#{directory_path}/mutator_#{iterator}"
			file = File.open(mutator_diff_path, 'w')
			file.puts(mutator_method)
			file.close

			iterator += 1
			mutator_method = ''
			add_line_into_mutator_method = false
		end

		if add_line_into_mutator_method and !line.start_with? ' def'
			if line.start_with? ' '
				mutator_method += (' ' + line)
			elsif line.start_with? '+'
				mutator_method += (' ' + line.sub!('+', ' '))
			end
		end
	end
	puts '-' * 20
end