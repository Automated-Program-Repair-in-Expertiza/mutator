require 'yaml'
require 'fileutils'
require 'parser'
require 'parser/current'
require_relative './string.rb'

parent_dir_path = File.expand_path("../../../", __FILE__)
folder_paths = YAML.load_file("./folder_path.yml")
fault_locations = YAML.load_file(folder_paths['FaultLocations'])

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	file_name = source_file_path.match(/[a-z_]+.rb/).to_s.chomp('.rb')
	class_name = file_name.camelize
	mutator_input_dir_path = folder_paths['MutatorInputDirPath']
	full_file_path = "#{mutator_input_dir_path}/#{file_name}.rb"
	mutator_copied_dir_path = folder_paths['MutatorCopiedDirPath']
	mutator_output_dir_path = folder_paths['MutatorOutputDirPath']
	mutator_script_path = folder_paths['MutatorScriptPath']

	puts "Copy file #{file_name}.rb"
	FileUtils.cp(full_file_path, mutator_copied_dir_path)

	puts "Start mutating #{file_name}.rb..."
	
	system("cd #{parent_dir_path}/mutant_rails_app/ && \
		  RAILS_ENV=test bundle exec mutant --require ./config/environment #{class_name} > \
		  #{mutator_output_dir_path} && \
		  cd #{mutator_script_path}")

	FileUtils.rm("#{mutator_copied_dir_path}/#{file_name}.rb")
	puts "Finish mutating for #{file_name}.rb"
	puts "--------------------\n"
end