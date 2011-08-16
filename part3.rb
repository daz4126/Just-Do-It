require 'sinatra'
require 'slim'
require 'sass'
require 'datamapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Task
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :completed_at, DateTime
  belongs_to :list
end

class List
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  has n, :tasks, :constraint => :destroy  
end

DataMapper.finalize

get('/styles.css'){ content_type 'text/css', :charset => 'utf-8' ; scss :styles }

get '/' do
  @lists = List.all(:order => [:name])
  slim :index
end

post '/:id' do
  List.get(params[:id]).tasks.create params['task']
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

post '/new/list' do
  List.create params['list']
  redirect '/'
end

delete '/list/:id' do
  List.get(params[:id]).destroy
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
form.new action="/new/list" method="POST"
  input type="text" name="list[name]"
  input type="submit" value="Add List >>"
ul.lists
  - @lists.each do |list|
    == slim :list, locals: { list: list }
    
@@list
li.list
  h2= list.name
  form.new action="/#{list.id}" method="POST"
    input type="text" name="task[name]"
  ul.tasks
    - list.tasks.each do |task|
      == slim :task, locals: { task: task }
  form.destroy action="/list/#{list.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="&times;"
    
@@task
li.task id=task.id class=(task.completed_at.nil? ? "" : "completed")
  = task.name
  form.update action="/task/#{task.id}" method="POST"
    input type="hidden" name="_method" value="PUT"
    input type="submit" value="&#10003;"
  form.delete action="/task/#{task.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="&times;"   
    
@@styles
.completed{
  text-decoration: line-through;
  }

.tasks{
  padding:0;
  list-style:none;
  }

.task{
  position:relative;
  padding:2px 0 2px 28px;
  border-bottom: dotted 1px #ccc;
}

form.update{
  position:absolute;
  bottom:2px;
  left:0;
  }
form.update input{
  background:white;
  color:white;
  padding:0 2px;
  border:solid 1px gray;
  cursor:pointer;
}

.tasks li.completed form.update input{
  color:#000;
  }

form.delete{
  display:inline;
  }
  
form.delete input{
  background:none;
  cursor:pointer;
  border:none;
  }
  
.lists{
  padding:0;
  list-style:none;
  overflow:hidden;
  }
  
.list{
  float: left;
  width:23%;
  margin:0 1%;
  border-top:solid 5px #ccc;
  }

