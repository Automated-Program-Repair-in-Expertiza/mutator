require 'yaml'
require_relative './method_finder.rb'
require_relative './string.rb'

# Generate the inputs of mutator
# prepare variables from YAML file
parent_dir_path = File.expand_path("../../../", __FILE__)
folder_paths = YAML.load_file("./folder_path.yml")
fault_locations = YAML.load_file(folder_paths['FaultLocations'] % {parent_dir_path: parent_dir_path})

method_finder = nil
# for each runtime exception error mutator file
# try to generate a new file only contains class declaration and certain method block
fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	num_of_line = content['LineNum']

	expertiza_file_path = folder_paths['ExpertizaFilePath'] % {parent_dir_path: parent_dir_path,
															   source_file_path: source_file_path}
	mutator_input_dir_path = folder_paths['MutatorInputDirPath'] % {parent_dir_path: parent_dir_path,
																	airbrake_group_id: airbrake_group_id}
	method_finder = MethodFinder.new(expertiza_file_path)
	first_line = ''
	snake_case_class_name = ''
	File.readlines(expertiza_file_path).each do |line|
		# find the class declaration line of origin file to
		# become the first line of new file
		if line.start_with? 'class'
			first_line = line 
			snake_case_class_name = line.match(/\s[a-zA-Z]+\s/).to_s.strip.underscore
			break
		end
	end

	# use method_finder.rb to find the method block containing target line
	method_block = method_finder.find(num_of_line)
	
	# if certain airbrake group dir is not exist, create one
	# use snage case class name as file name
	Dir.mkdir(mutator_input_dir_path) unless Dir.exists?(mutator_input_dir_path)
	mutator_input_file_path = "#{mutator_input_dir_path}/#{snake_case_class_name}.rb"

	# write file only contains class declaration and the method block containing ceratin line
	file = File.open(mutator_input_file_path, 'w')
	file.puts(first_line)
	file.puts('  ' + method_block)
	file.puts('end')
	file.close
	puts "Mutator-inputs #{snake_case_class_name}.rb is generated!"
end