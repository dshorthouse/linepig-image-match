#!/usr/bin/env ruby
# encoding: utf-8
require_relative '../environment.rb'

puts 'Starting to build library of descriptors'
descriptors = Linepig::DescriptorExtractor.new
descriptors.create
puts 'Done'