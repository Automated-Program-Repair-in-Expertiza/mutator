require 'yaml'
require 'pry'

# prepare variables from YAML file
parent_dir_path = File.expand_path("../../../", __FILE__)
folder_paths = YAML.load_file("./folder_path.yml")
fault_locations = YAML.load_file(folder_paths['FaultLocations'] % {parent_dir_path: parent_dir_path})

# for each runtime exception error mutator file
# try to replace the buggy method with mutated new method
# and run test cases
fault_locations.each do |name, content|
	airbrake_group_id = content['AirbrakeGroupId']
	source_file_path = content['File']
	test_cases = content['Test']
	source_file_path = content['File']
	file_name = source_file_path.match(/[a-z_]+.rb/).to_s.chomp('.rb')

	expertiza_file_path = folder_paths['ExpertizaFilePath'] % {parent_dir_path: parent_dir_path,
															   source_file_path: source_file_path}
	mutator_input_dir_path = folder_paths['MutatorInputDirPath'] % {parent_dir_path: parent_dir_path,
																	airbrake_group_id: airbrake_group_id}
	mutator_splitted_new_method_dir_path = folder_paths['MutatorSplittedNewMethodDirPath'] % {parent_dir_path: parent_dir_path,
																							  airbrake_group_id: airbrake_group_id}
	mutator_script_path = folder_paths['MutatorScriptPath'] % {parent_dir_path: parent_dir_path}
	
	# get the whole file content of certain file
	# also get original method content from mutator input file
	whole_file_content = File.read(expertiza_file_path)
	new_whole_file_content = whole_file_content
	mutator_input_file_path = "#{mutator_input_dir_path}/#{file_name}.rb"
	original_method = File.read(mutator_input_file_path).gsub!(/^.*\n\s\sdef/, '  def').gsub!(/end\n$/, '')

	# for each mutator file in airbrake group dir, do sth...
	iterator = 1
	Dir.foreach(mutator_splitted_new_method_dir_path) do |file_name|
		# replace original method with mutated new method
		next if file_name == '.' or file_name == '..'
		mutator_method = File.read("#{mutator_splitted_new_method_dir_path}/#{file_name}")
		file = File.open(expertiza_file_path, 'w')
		new_whole_file_content = new_whole_file_content.sub(original_method, mutator_method)
		file.puts(new_whole_file_content)
		file.close

		# goto expertiza dir; run the test; go back to current dir
		test_cases.each do |test_case_path|
			system("cd #{parent_dir_path}/expertiza/ && \
			  		rspec #{parent_dir_path}/expertiza/#{test_case_path} && \
			  		cd #{mutator_script_path}")

			# if shell script exit 0 (w/o error), record time, file name and show SUCCESS
			# if shell script exit with other number (with error), show fail
			file = File.open("#{parent_dir_path}/mutator/results/test-results", 'a')
			file.puts("AirbrakeGroupId: #{airbrake_group_id}") if iterator == 1
			if $?.exitstatus == 0
				file.puts("#{Time.now}\t\t#{file_name}\t\tSUCCESS")
			else
				file.puts("#{Time.now}\t\t#{file_name}\t\tfail")
			end
			file.close
		end

		# update intermediate variables
		original_method = mutator_method
		iterator += 1
	end

	# add separator
	file = File.open("#{parent_dir_path}/mutator/results/test-results", 'a')
	file.puts("--------------------\n")
	file.close

	# recover modified file
	system("cd ../../expertiza && git checkout . && cd ../mutator/lib")
	# mutator_method = original_method
	# original_method = File.read(mutator_input_file_path).gsub!(/^.*\n\s\sdef/, '  def').gsub!(/end\n$/, '')
	# file = File.open(expertiza_file_path, 'w')
	# new_whole_file_content = new_whole_file_content.sub(mutator_method, original_method)
	# file.puts(new_whole_file_content)
	# file.close
end


