#!/bin/sh

echo '=====Generate mutator inputs=========='
ruby mutator_inputs_generator.rb
echo 'Sleep 5 seconds'
sleep 5

echo '=====Generate mutants================='
ruby mutator.rb
echo 'Sleep 5 seconds'
sleep 5

echo '=====Separate mutant outputs=========='
ruby mutator_outputs_separator.rb
echo 'Sleep 5 seconds'
sleep 5

echo '=====Validate mutants================='
ruby mutator_validator.rb