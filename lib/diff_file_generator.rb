require 'yaml'
require_relative './string.rb'

parent_dir_path = File.expand_path("../../../", __FILE__)
folder_paths = YAML.load_file("./folder_path.yml")
fault_locations = YAML.load_file(folder_paths['FaultLocations'])

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']

	mutator_output_dir_path = folder_paths['MutatorOutputDirPath']
	mutator_splitted_new_method_dir_path = folder_paths['MutatorSplittedNewMethodDirPath']

	iterator = 1
	mutator_method = ''
	add_line_into_mutator_method = false
	puts "Separate mutators for #{airbrake_group_id}"

	File.readlines(mutator_output_dir_path).each do |line|
		if line.start_with? ' def'
			mutator_method += (' ' + line)
			add_line_into_mutator_method = true
		end

		if line.start_with? '--'
			Dir.mkdir(mutator_splitted_new_method_dir_path) unless Dir.exists?(mutator_splitted_new_method_dir_path)

			puts "mutator_#{iterator}"
			mutator_diff_path = "#{mutator_splitted_new_method_dir_path}/mutator_#{iterator}"
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