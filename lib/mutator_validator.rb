require 'yaml'
require 'pry'

parent_dir_path = File.expand_path("../../../", __FILE__)
fault_locations = YAML.load_file("#{parent_dir_path}/mutator/results/fault-localization.yml")

fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	test_cases = content['Test']
	source_file_path = content['File']
	file_name = source_file_path.match(/[a-z_]+.rb/).to_s.chomp('.rb')

	full_file_path = "#{parent_dir_path}/expertiza/#{source_file_path}"
	whole_file_content = File.read(full_file_path)
	new_whole_file_content = whole_file_content
	mutator_input_file_path = "#{parent_dir_path}/mutator/results/mutator-inputs/#{airbrake_group_id}/#{file_name}.rb"
	original_method = File.read(mutator_input_file_path).gsub!(/^.*\n\s\sdef/, '  def').gsub!(/end\n$/, '')
	directory_path = "#{parent_dir_path}/mutator/results/mutator-splitted-new-methods/#{airbrake_group_id}"

	iterator = 1
	Dir.foreach(directory_path) do |file_name|
		next if file_name == '.' or file_name == '..'
		mutator_method = File.read("#{directory_path}/#{file_name}")
		file = File.open(full_file_path, 'w')
		new_whole_file_content = new_whole_file_content.sub(original_method, mutator_method)
		file.puts(new_whole_file_content)
		file.close

		test_cases.each do |test_case_path|
			system("cd #{parent_dir_path}/mutant_rails_app/ && \
			  		rspec #{parent_dir_path}/expertiza/#{test_case_path} && \
			  		cd #{parent_dir_path}/mutator/lib")

			file = File.open("#{parent_dir_path}/mutator/results/test-results", 'a')
			file.puts("AirbrakeGroupId: #{airbrake_group_id}") if iterator == 1
			if $?.exitstatus == 0
				file.puts("#{Time.now}\t\t#{file_name}\t\tSUCCESS")
			else
				file.puts("#{Time.now}\t\t#{file_name}\t\tfail")
			end
			file.close
		end
		original_method = mutator_method
		iterator += 1
	end

	# add separator
	file = File.open("#{parent_dir_path}/mutator/results/test-results", 'a')
	file.puts("--------------------\n")
	file.close

	# recover modified file
	original_method = File.read(mutator_input_file_path).gsub!(/^.*\n\s\sdef/, '  def').gsub!(/end\n$/, '')
	file = File.open(full_file_path, 'w')
	new_whole_file_content = new_whole_file_content.sub(mutator_method, original_method)
	file.puts(new_whole_file_content)
	file.close
end


