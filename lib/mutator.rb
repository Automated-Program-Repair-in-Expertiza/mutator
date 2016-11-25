require 'yaml'
require 'fileutils'
require 'parser'
require 'parser/current'
require_relative './string.rb'

# prepare variables from YAML file
parent_dir_path = File.expand_path("../../../", __FILE__)
folder_paths = YAML.load_file("./folder_path.yml")
fault_locations = YAML.load_file(folder_paths['FaultLocations'] % {parent_dir_path: parent_dir_path})

# for each runtime exception error mutator input file, try to use `mutant` gem to do mutant
fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	file_name = source_file_path.match(/[a-z_]+.rb/).to_s.chomp('.rb')
	class_name = file_name.camelize

	# read path from folder_path.yml file
	mutator_input_dir_path = folder_paths['MutatorInputDirPath'] % {parent_dir_path: parent_dir_path,
																	airbrake_group_id: airbrake_group_id}
	full_file_path = "#{mutator_input_dir_path}/#{file_name}.rb"
	mutator_copied_dir_path = folder_paths['MutatorCopiedDirPath'] % {parent_dir_path: parent_dir_path}
	mutator_output_dir_path = folder_paths['MutatorOutputDirPath'] % {parent_dir_path: parent_dir_path,
																	  airbrake_group_id: airbrake_group_id}
	mutator_script_path = folder_paths['MutatorScriptPath'] % {parent_dir_path: parent_dir_path}

	# copy mutator input file to mutant_rails_app
	# in order to do mutate for certain buggy method only
	puts "Copy file #{file_name}.rb"
	FileUtils.cp(full_file_path, mutator_copied_dir_path)

	puts "Start mutating #{file_name}.rb..."
	
	# run shell script in ruby script
	# goto certain file; do the mutation; store output to output file; go back to current dir
	system("cd #{parent_dir_path}/mutant_rails_app/ && \
		  RAILS_ENV=test bundle exec mutant --require ./config/environment #{class_name} > \
		  #{mutator_output_dir_path} && \
		  cd #{mutator_script_path}")

	# remove the copied file
	FileUtils.rm("#{mutator_copied_dir_path}/#{file_name}.rb")
	puts "Finish mutating for #{file_name}.rb"
	puts "--------------------\n"
end