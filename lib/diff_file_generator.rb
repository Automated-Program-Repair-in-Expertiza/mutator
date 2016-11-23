require 'yaml'
require_relative './string.rb'

parent_dir_path = File.expand_path("../../../", __FILE__)
fault_locations = YAML.load_file("#{parent_dir_path}/mutator/results/fault-localization.yml")

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	output_file_path = "#{parent_dir_path}/mutator/results/mutator-outputs/#{airbrake_group_id}"
	directory_path = "#{parent_dir_path}/mutator/results/mutator-splited-new-methods/#{airbrake_group_id}"

	iterator = 1
	temp_content = ''
	add_line_into_temp_content = false
	puts "Separate mutators for #{airbrake_group_id}"

	File.readlines(output_file_path).each do |line|
		if line.start_with? ' def'
			temp_content += (' ' + line)
			add_line_into_temp_content = true
		end

		if line.start_with? '--'
			Dir.mkdir(directory_path) unless File.exists?(directory_path)
			full_file_path = "#{parent_dir_path}/expertiza/#{source_file_path}"

			first_line = ''
			file_name = ''
			File.readlines(full_file_path).each do |line|
				# find the class declaration line of origin file to
				# become the first line of new file
				if line.start_with? 'class'
					first_line = line 
					file_name = line.match(/\s[a-zA-Z]+\s/).to_s.strip.underscore
					break
				end
			end
			puts "mutator_#{iterator}"
			mutator_diff_path = "#{directory_path}/mutator_#{iterator}"
			file = File.open(mutator_diff_path, 'w+')
			file.puts(first_line)
			file.puts(temp_content)
			file.puts('end')
			file.close

			iterator += 1
			temp_content = ''
			add_line_into_temp_content = false
		end

		if add_line_into_temp_content and !line.start_with? ' def'
			if line.start_with? ' '
				temp_content += (' ' + line)
			elsif line.start_with? '+'
				temp_content += (' ' + line.sub!('+', ' '))
			end
		end
	end
	puts '-' * 20
end