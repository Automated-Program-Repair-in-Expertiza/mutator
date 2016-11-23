require 'yaml'
require 'fileutils'
require 'parser'
require 'parser/current'
require_relative './string.rb'

parent_dir_path = File.expand_path("../../../", __FILE__)
fault_locations = YAML.load_file("#{parent_dir_path}/mutator/results/fault-localization.yml")

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	file_name = source_file_path.match(/[a-z_]+.rb/).to_s.chomp('.rb')
	class_name = file_name.camelize
	full_file_path = "#{parent_dir_path}/mutator/results/mutator-inputs/#{airbrake_group_id}/#{file_name}.rb"
	dest_folder = "#{parent_dir_path}/mutant_rails_app/app/mutator-inputs/"

	puts "Copy file #{file_name}.rb"
	FileUtils.cp(full_file_path, dest_folder)

	puts "Start mutating #{file_name}.rb..."
	system("cd #{parent_dir_path}/mutant_rails_app/ && \
		  RAILS_ENV=test bundle exec mutant --require ./config/environment #{class_name} > \
		  #{parent_dir_path}/mutator/results/mutator-outputs/#{airbrake_group_id} && \
		  cd #{parent_dir_path}/mutator/lib")
	FileUtils.rm("#{dest_folder}/#{file_name}.rb")
	puts "Finish mutating for #{file_name}.rb"
	puts "--------------------\n"
end