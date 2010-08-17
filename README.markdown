# Passport Sinatra Example

Get up and running with Oauth for every service on the planet immediately.

    gem install passport
    git clone git@github.com:viatropos/passport-sinatra-example.git
    cd passport-sinatra-example
    
Then fill out `tokens.yml` with your app key/secret for Facebook, and run:

    ruby app.rb
    
Go to [`http://localhost:4567/`](http://localhost:4567/), and through the power of Oauth you'll retrieve your Facebook profile.  All that with this:

    require 'rubygems'
    require 'haml'
    require 'passport'
    require 'sinatra'

    enable :sessions

    use Rack::Context
    use Passport::Filter

    Passport.configure("tokens.yml")

    get "/" do
      haml :index
    end

    post "/" do
      Passport.authenticate do |token|
        session[:facebook] = token.to_hash
        redirect "/profile"
      end
    end

    get "/profile" do
      token   = FacebookToken.new(session[:facebook])
      @me      = JSON.parse(token.get("/me"))
      haml :show
    end

    __END__
    @@ layout
    !!! 5
    %head
      %title Passport Sinatra
    %body
      = yield
    
    @@ index
    %form{:action => "/", :method => :post}
      %input{:type => :hidden, :name => :oauth_provider, :value => :facebook}
      %input{:type => :hidden, :name => :authentication_type, :value => :user}
      %input{:type => :submit, :value => "Login with Facebook"}
  
    @@ show
    %a{:href => @me["link"]}
      %h1= "#{@me["name"]}, Your on Facebook!"
      %img{:src => "https://graph.facebook.com/#{@me["id"]}/picture"}

The magic happens here:

    post "/" do
      Passport.authenticate do |token|
        session[:facebook] = token.to_hash
        redirect "/profile"
      end
    end
    
[Passport](http://github.com/viatropos/passport) is a Rack-based Oauth/OpenID wrapper that makes them dead-easy to use.  `Passport.authenticate` returns a Rack redirect to begin authentication, and when the service redirects back, it runs the `token` block.  I put the token in the session for demonstration purposes, it's much safer to store the details in the database or through some other means, but this works.

You can swap out Facebook with [the other Oauth providers](http://github.com/viatropos/passport/tree/master/lib/passport/oauth/tokens) by just changing the class (`TwitterToken`, `GoogleToken`, etc.).