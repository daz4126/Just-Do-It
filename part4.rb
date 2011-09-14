enable :inline_templates

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
    title= settings.title
    link href="http://fonts.googleapis.com/css?family=#{settings.fonts.join('|')}" rel='stylesheet'
    link rel="stylesheet" media="screen, projection" href="/styles.css"
    /[if lt IE 9]
      script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"
  body
    h1.logo= settings.title
    == yield
    
@@index
form.new-list action="/new/list" method="POST"
  input type="text" name="list[name]"
  input.button type="submit" value="Add List >>"
ul.lists
  - @lists.each do |list|
    == slim :list, locals: { list: list }
    
@@list
li.list
  h1= list.name
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
    -if task.completed_at.nil?
      input type="submit" value="  " title="Complete Task"
    -else
      input type="submit" value="&#10003;" title="Uncomplete Task"
  form.delete action="/task/#{task.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="&times;" title="Delete Task"  
    
@@styles
$orange:#D78123;
$blue:#1E1641;
$green:#02d330;
$grey: #999;

$background:$blue;
$logo-color:white;
$logo-font:"Anton",sans-serif;
$heading-color:$orange;
$heading-font:"Anton",sans-serif;

@mixin button($color){
    background:$color;
    border: 2px solid darken($color,15%);
    cursor: pointer;
    color: #fff;
    width: 150px;
    margin-left:4px;
}

body{
  background:$background;
  padding:0;
  margin:0;
  } 

h1.logo{
  font-family: $logo-font;
  font-size: 24px;
  color:$logo-color;
  padding:64px 0 0;
  margin: 0 auto;
  text-transform: uppercase;
  text-align: center;
  font-weight: normal;
  letter-spacing: 0.3em;
  background: transparent url(/logo.png) 50% 0 no-repeat;
  }

.new-list{
  margin: 0 auto;
  padding: 10px;
  width: 424px;
  input{
    padding: 4px 8px;
    font-size: 24px;
    border:none;
    font-weight: bold;
    width: 250px;
    }
  .button{
    @include button($orange);
    }
  }


.completed{
  text-decoration: line-through;
  }

.tasks{
  padding:0;
  list-style:none;
  }

.task{
  color:#444;
  position:relative;
  padding:2px 0 2px 28px;
  border-bottom: dotted 1px #ccc;
}

form.update{
  position:absolute;
  bottom:2px;
  left:0;
  input{
    background: white;
    color: white;
    padding:0 2px;
    border:solid 1px $grey;
    cursor:pointer;
    width:20px;
    height:20px;
    }
  }

.tasks li.completed form.update input{
  color:$green;
  font-weight: bold;
  }

form.delete{
  display:inline;
  }
  
form.delete input{
  color: white;
  background:none;
  cursor:pointer;
  border:none;
  }
  
.lists{
  padding:0;
  list-style:none;
  overflow:hidden;
  clear: left;
  padding-top: 20px;
  }
  
.list{
  float: left;
  position: relative;
  width:21%;
  margin:0 1% 20px;
  padding: 0 1% 8px;
  border-top: solid 5px $green;
  background: #fff;
  background: rgba(#fff,0.7);
  padding-bottom: 20px;

  h1{  
    text-align:center;
    font-family:$heading-font;
    font-weight: normal;
    font-size: 24px;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color:$heading-color;
    margin:0;
    }
  form.new input{
    width: 80%;
    display: block;
    margin:0 auto 8px;
    }
  form.destroy input{
    display: block;
    margin:0;
    position:absolute;
    top:2px;
    right:2px;
    background: transparent;
    border: 1px solid $grey;
    color: $grey;
    font-size:16px;
    opacity:0.6;
    &:hover{
      opacity:1;
      background: #fff;
      color: $green;
      }
    } 
  }
