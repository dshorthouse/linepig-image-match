# encoding: utf-8

module Sinatra
  module Linepig
    module Routing
      module Main

        def self.registered(app)

          app.get '/' do
            haml :home
          end

          app.get '/main.css' do
            content_type 'text/css', charset: 'utf-8'
            scss :main
          end

          app.post '/matches' do
            file = params[:file] || (params[:find] && params[:find][:file]) || nil
            if !file.nil?
              file_name = file[:filename]
              file_path = File.join([Dir.mktmpdir] + [file_name.gsub( /[^a-zA-Z0-9_\.]/, '_')])
              FileUtils.mv(file[:tempfile].path, file_path)
              execute_match(file_path)
            end
            haml :matches
          end

          app.not_found do
            status 404
            haml :oops
          end

        end

      end
    end
  end
end