require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'rspec/autorun'

$:.unshift("/Applications/Zephyros.app/Contents/Resources/libs")
$:.unshift File.expand_path('../../lib', __FILE__)

require 'beer'

