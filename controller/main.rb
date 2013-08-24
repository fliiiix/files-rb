# encoding: UTF-8
require "sinatra"
require "yaml"
require_relative "model.rb"
require_relative "config.rb"
require_relative "error.rb"
require_relative "login.rb"

get "/" do
  @files = UploadFile.all
  erb :index
end

get "/upload" do
  protected!
  erb :upload
end

post "/upload" do
  protected!

  if params[:file] != nil
    filename = params[:file][:filename]
    filepath = params[:file][:tempfile].to_path
  else
    filename = ""
    filepath = ""
  end

  file = UploadFile.new(:fileName => filename, :filePath => filepath, :url => filename, :counter => 0)

  if file.save
    redirect "/"
  end

  @meldung = "Error(s): " + file.errors.map {|k,v| "#{k}: #{v}"}.to_s
  erb :index
end

get "/:name/?" do |name|
  file = UploadFile.find_by_url(name)
  halt 404 if file == nil

  begin
    file.counter += 1
    file.save  
  rescue Exception => e
    puts e
  end

  send_file file.filePath, :filename => file.fileName, :disposition => (image?(file.fileName) ? 'inline' : 'attachment')
end