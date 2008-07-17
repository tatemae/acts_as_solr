require 'rubygems'
require 'rake'
require 'net/http'
require 'active_record'
require "#{File.dirname(__FILE__)}/../../config/environment.rb"

namespace :solr do

  desc 'Starts Solr. Options accepted: RAILS_ENV=your_env, PORT=XX. Defaults to development if none.'
  task :start do
    begin
      n = Net::HTTP.new('localhost', SOLR_PORT)
      n.request_head('/').value 

    rescue Net::HTTPServerException #responding
      puts "Port #{SOLR_PORT} in use" and return

    rescue Errno::ECONNREFUSED #not responding
      Dir.chdir(SOLR_PATH) do
        pid = fork do
          #STDERR.close
          exec "java -Dsolr.data.dir=#{SOLR_DATA_PATH} -Djetty.logs=#{SOLR_LOGS_PATH} -Djetty.port=#{SOLR_PORT} -jar start.jar"
        end
        sleep(5)
        File.open("#{SOLR_PIDS_PATH}/#{ENV['RAILS_ENV']}_pid", "w"){ |f| f << pid}
        puts "#{ENV['RAILS_ENV']} Solr started successfully on #{SOLR_PORT}, pid: #{pid}."
      end
    end
  end
  
  desc 'Stops Solr. Specify the environment by using: RAILS_ENV=your_env. Defaults to development if none.'
  task :stop do
    fork do
      file_path = "#{SOLR_PIDS_PATH}/#{ENV['RAILS_ENV']}_pid"
      if File.exists?(file_path)
        File.open(file_path, "r") do |f| 
          pid = f.readline
          Process.kill('TERM', pid.to_i)
        end
        File.unlink(file_path)
        Rake::Task["solr:destroy_index"].invoke if ENV['RAILS_ENV'] == 'test'
        puts "Solr shutdown successfully."
      else
        puts "PID file not found at #{file_path}. Either Solr is not running or no PID file was written."
      end
    end
  end
  
  desc 'Remove Solr index'
  task :destroy_index do
    raise "In production mode.  I'm not going to delete the index, sorry." if ENV['RAILS_ENV'] == "production"
    if File.exists?("#{SOLR_DATA_PATH}")
      Dir["#{SOLR_DATA_PATH}/index/*"].each{|f| File.unlink(f)}
      Dir.rmdir("#{SOLR_DATA_PATH}/index")
      puts "Index files removed under " + ENV['RAILS_ENV'] + " environment"
    end
  end
end
