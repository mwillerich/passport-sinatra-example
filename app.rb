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
  me      = JSON.parse(token.get("/me"))
  @profile = {
    :id     => me["id"],
    :name   => me["name"],
    :photo  => "https://graph.facebook.com/#{me["id"]}/picture",
    :url    => me["link"]
  }
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
%a{:href => @profile[:url]}
  %h1 Your on Facebook!
  %img{:src => @profile[:photo]}