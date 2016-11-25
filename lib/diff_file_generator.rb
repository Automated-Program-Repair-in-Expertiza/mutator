require 'yaml'
require_relative './string.rb'

# prepare variables from YAML file
parent_dir_path = File.expand_path("../../../", __FILE__)
folder_paths = YAML.load_file("./folder_path.yml")
fault_locations = YAML.load_file(folder_paths['FaultLocations'] % {parent_dir_path: parent_dir_path})

# for each runtime exception error mutator file, try to separate each mutant
fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']

	# read path from folder_path.yml file
	mutator_output_dir_path = folder_paths['MutatorOutputDirPath'] % {parent_dir_path: parent_dir_path, 
																	  airbrake_group_id: airbrake_group_id}
	mutator_splitted_new_method_dir_path = folder_paths['MutatorSplittedNewMethodDirPath'] % {parent_dir_path: parent_dir_path,
																							  airbrake_group_id: airbrake_group_id}
    # start separating mutants
	iterator = 1
	mutator_method = ''
	add_line_into_mutator_method = false
	puts "Separate mutators for #{airbrake_group_id}"

	# read the mutator output file line by line
	File.readlines(mutator_output_dir_path).each do |line|
		# if one line start with ' def'
		# add this line to mutator_method and set the add line flag to true
		if line.start_with? ' def'
			mutator_method += (' ' + line)
			add_line_into_mutator_method = true
		end

		# if one line start with '--', it means this mutant is over
		# if the dir is not exist, create a new dir for this airbrake group
		# puts mutator_methos into new file
		# update iterator. reset mutator_method and add line flag
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

		# if add line flag is true and this line is not start with ' def'
		# if this line start with white space or '+', add this line
		# if this line start with '-', do not add this line
		if add_line_into_mutator_method and !line.start_with? ' def'
			if line.start_with? ' '
				mutator_method += (' ' + line)
			elsif line.start_with? '+'
				mutator_method += (' ' + line.sub!('+', ' '))
			end
		end
	end
	# print console separator
	puts '-' * 20
end