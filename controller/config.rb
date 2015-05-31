use Rack::Session::Pool

helpers do
  def admin? ; session["isLogdIn"] == true || Debug; end
  def protected! ; halt 401 unless admin? ; end
  def image?(file) file.to_s.include?(".gif") or file.to_s.include?(".png") or file.to_s.include?(".jpg") or file.to_s.include?(".jpeg") end
end

configure :development do
  set :views, Proc.new { File.join(root, "../views") }
  set :public_folder, Proc.new { File.join(root, "../public") }

  MongoMapper.database = 'files'
  Debug = true
end

configure :production do
  set :views, Proc.new { File.join(root, "../views") }
  set :public_folder, Proc.new { File.join(root, "../public") }

  # mongodb://user:pass@host:port/dbname
  MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_FILES_URI']}}, 'production')
  Debug = false
end