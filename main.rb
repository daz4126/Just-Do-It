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
  belongs_to :list
end
class List
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  has n, :tasks, :constraint => :destroy  
end
DataMapper.finalize
DataMapper.auto_migrate!
get('/styles.css'){ content_type 'text/css', :charset => 'utf-8' ; scss :styles }
get '/' do
  @lists = List.all(:order => [:name])
  slim :index
end
post '/:id' do
  List.get(params[:id]).tasks.create params['task']
  redirect '/'
end
put '/task/:id' do
  task = Task.get params[:id]
  task.completed_at = task.completed_at.nil? ? Time.now : nil
  task.save
  redirect '/'
end
delete '/task/:id' do
  Task.get(params[:id]).destroy
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
  input type="submit" value="+ List"
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
      li.task id=task.id class=(task.completed_at.nil? ? "" : "completed")
        = task.name
        form.update action="/task/#{task.id}" method="POST"
          input type="hidden" name="_method" value="PUT"
          input type="submit" value="&#10003;"
        form.delete action="/task/#{task.id}" method="POST"
          input type="hidden" name="_method" value="DELETE"
          input type="submit" value="&times;"
  form.destroy action="/list/#{list.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="&times;"
@@styles
body{font:11px/1 Arial, Helvetica, sans-serif;}
.completed{text-decoration: line-through;}
.lists,.tasks{padding:0;list-style:none;overflow:hidden;}
.list{width:18%;margin:10px 1%;float:left;position:relative;
form.destroy{position:absolute;right:0;top:0;display:none;margin:0;padding:0}
&:hover form.destroy{display:block;}
form.new{input{width:80%;display:block;margin:0 auto;}}
h2{text-align:center;margin:0;}}
.task{overflow:hidden;border-bottom:dotted 1px #ccc;
padding:0;position:relative;padding:2px 0 2px 28px;
form.update{position:absolute;bottom:2px;left:0;
input{background:white;color:white;padding:0 2px;border:solid 1px gray;cursor:pointer;}}
&.completed form.update input{color:#000;}
form.delete{display:inline;
input{color:#fff;background:none;cursor:pointer;border:none;}}
 &:hover form.delete input{color:#000;}}
