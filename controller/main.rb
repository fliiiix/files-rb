# encoding: UTF-8
require "sinatra"
require "bcrypt"
require "date"

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

  file = UploadFile.new(:fileName => filename, :filePath => filepath, :url => filename, :counter => 0, :user => params[:user], :pass => params[:pass])

  if file.save
    redirect "/"
  end

  @meldung = "Error(s): " + file.errors.map {|k,v| "#{k}: #{v}"}.to_s
  erb :index
end

get "/auth/:name" do |name|
  # current time
  t = Time.new

  if FailLogin.where(:ip => request.ip, :year => t.year, :month => t.month, :day => t.day).count >= 20
    redirect "/lock"
  end

  @name = name
  erb :auth
end

post "/auth/:name" do |name|
  file = UploadFile.find_by_url(name)
  halt 404 if file == nil

  if file.user != params[:username] || file.pass != params[:pass]
    # current time
    t = Time.new

    fail = FailLogin.new(:ip => request.ip, :year => t.year, :month => t.month, :day => t.day)
    fail.save

    if FailLogin.where(:ip => request.ip, :year => t.year, :month => t.month, :day => t.day).count > 20
      redirect "/lock"
    end

    redirect "/auth/" + name
  end

  begin
    file.counter += 1
    file.save  
  rescue Exception => e
    puts e
  end

  send_file file.filePath, :filename => file.fileName, :disposition => (image?(file.fileName) ? 'inline' : 'attachment')
end

get "/lock" do
  erb :lock
end

get "/admin/lock" do
  protected!
  # current time
  t = Time.new
  oldIp = nil
  @fails = Array.new

  fails = FailLogin.where(:year => t.year, :month => t.month, :day => t.day)
  for fail in fails do
    if oldIp != fail.ip
      @fails << FailLoginViewModel.new(fail.ip, FailLogin.where(:ip => request.ip, :year => t.year, :month => t.month, :day => t.day).count)
    end
    oldIp = fail.ip
  end
  erb :adminLock
end

get "/unlock/:ip" do |ip|
  FailLogin.destroy_all(:ip => ip)
  redirect "/admin/lock"
end

get "/:name/?" do |name|
  file = UploadFile.find_by_url(name)
  halt 404 if file == nil

  unless file.user.to_s.empty? && file.pass.to_s.empty?
    redirect "/auth/" + name
  end

  begin
    file.counter += 1
    file.save  
  rescue Exception => e
    puts e
  end

  send_file file.filePath, :filename => file.fileName, :disposition => (image?(file.fileName) ? 'inline' : 'attachment')
end
