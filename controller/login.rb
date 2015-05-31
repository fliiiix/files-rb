get "/login/?" do
	@loginPage = true
	erb :login
end

post '/login/?' do
  if params['username'] == ENV['USER'] && params['pass'] == BCrypt::Engine.hash_secret(pass, ENV['SALT'])
    session["isLogdIn"] = true
    redirect '/'
  else
    halt 401
  end
end

get('/logout/?'){ session["isLogdIn"] = false ; redirect '/' }





