#!/usr/bin/env ruby
require './environment'

class LINEPIG < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :haml, :format => :html5
  set :public_folder, 'public'

  register Sinatra::ConfigFile
  config_file File.join(root, 'config.yml')

  helpers Sinatra::ContentFor
  helpers Sinatra::Linepig::Match

  register Sinatra::Linepig::Routing::Main

  run! if app_file == $0
end