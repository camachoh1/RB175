require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"
require 'pry'

#setting up sessions.
configure do
  enable :sessions
  set :sessions_secret, 'super secret'
end

#provides file directory for tests or program execution
def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

#renders markdown file in html
def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

#load files from 
def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    erb render_markdown(content)
  else
    headers["Content-Type"] = "text/plain"
    content
  end
end

def user_signed_in?
  session.key?(:username)
end

def require_signed_in_user
  unless user_signed_in?
    session[:message] = "You must be signed in to do that."
    redirect "/"
  end
end 

#index page 
get "/" do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
end

#new document page
get "/new" do
  require_signed_in_user

  erb :new
end

# display document
get "/:filename" do

  file_path = File.join(data_path, params[:filename])

  if File.exist?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end

#edit document
get "/:filename/edit" do
  require_signed_in_user

  file_path = File.join(data_path, params[:filename])
  @filename = params[:filename]
  @content = File.read(file_path)
  erb :edit
end


get "/users/signin" do
  erb :signin
end

post "/users/signin" do
  if params[:username] == "admin" && params[:password] == "secret"
    session[:username] = params[:username]
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid credentials"
    status 422
    erb :signin
  end
end

post "/users/signout" do
  session.delete(:username)
  session[:message] = "You have been signed out."
  redirect "/"
end

#create a document
post "/create" do
  require_signed_in_user
  filename = params[:filename].to_s

  if filename.size == 0
    session[:message] = "A name is required."
    status 422
    erb :new
  else
    file_path = File.join(data_path, filename)
    File.write(file_path, "")
    
    session[:message] = "#{params[:filename]} has been created."
    
    redirect "/"
  end
end

#saving changes to the document
post "/:filename" do
  require_signed_in_user

  file_path = File.join(data_path, params[:filename])
  File.write(file_path, params[:content])
  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end

#delete a document
post "/:filename/delete" do
  require_signed_in_user
  file_path = File.join(data_path, params[:filename])

  File.delete(file_path)

  session[:message] = "#{params[:filename]} has been deleted."
  redirect "/"
end