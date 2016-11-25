#!/bin/sh

ruby mutator_inputs_generator.rb
echo 'Sleep 5 seconds'
sleep 5

ruby mutator.rb
echo 'Sleep 5 seconds'
sleep 5

ruby mutator_outputs_separator.rb
echo 'Sleep 5 seconds'
sleep 5

ruby mutator_validator.rb