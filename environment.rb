require 'bundler'
require 'tilt/haml'
require 'tilt/sass'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/config_file'
require 'yaml'
require 'thin'
require 'require_all'
require 'ropencv'

require_all 'lib'
require_all 'routes'
require_all 'helpers'

register Sinatra::ConfigFile
config_file File.join(File.dirname(__FILE__), 'config.yml')