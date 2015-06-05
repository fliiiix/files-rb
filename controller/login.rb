get "/login/?" do
	@loginPage = true
	erb :login
end

post '/login/?' do
  if params['username'] == ENV['USER'] && ENV['PASS']  == BCrypt::Engine.hash_secret(params['pass'], ENV['SALT'])
    session["isLogdIn"] = true
    redirect '/'
  else
    halt 401
  end
end

get('/logout/?'){ session["isLogdIn"] = false ; redirect '/' }
