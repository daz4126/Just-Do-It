require 'sinatra'
require 'slim'
require 'sass'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Task
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :completed_at, DateTime
end

DataMapper.finalize

get '/' do
  @tasks = Task.all
  slim :index
end

post '/' do
  Task.create params['task']
  redirect '/'
end

delete '/task/:id' do
  Task.get(params[:id]).destroy
  redirect '/'
end

put '/task/:id' do
  task = Task.get params[:id]
  task.completed_at = task.completed_at.nil? ? Time.now : nil
  task.save
  redirect '/'
end

__END__
@@layout
doctype html
html
  head
  meta charset="utf-8"
  title To Do
  link rel="stylesheet" media="screen, projection" href="/styles.css"
  /[if lt IE 9]
    script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"
  body
    h1 Just Do It!
    == yield
    
@@index
form.new action="/" method="POST"
  input type="text" name="task[name]"
  input type="submit" value="Add Task >>"
  
h2 My Tasks

ul.tasks
  - @tasks.each do |task|
    == slim :task, locals: { task: task }
    
@@task
li.task id=task.id class=(task.completed_at.nil? ? "" : "completed")
  = task.name
  = " (completed on #{task.completed_at.strftime('%d %b %Y')})" if task.completed_at
  form.update action="/task/#{task.id}" method="POST"
    input type="hidden" name="_method" value="PUT"
    input type="submit" value="&#10003;"
  form.delete action="/task/#{task.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="&times;"
