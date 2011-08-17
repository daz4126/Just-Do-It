set :title, "Just Do It!"
set :fonts, %w[ Pacifico Slackey Coda Gruppo Bevan Corben ]

enable :inline_templates

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
    input type="submit" value="&#10003;"
  form.delete action="/task/#{task.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="&times;"   
    
@@styles
$orange:#fcc647;
$blue:#477dfc;
$green:#47FD6B;

$background:lighten($blue,10%);
$logo-color:$green;
$logo-font:"Slackey",sans-serif;
$heading-color:$blue;
$heading-font:"Pacifico",sans-serif;


@mixin cicada-stripes($color:#ccc){
background-color: $color;
background-image: -webkit-linear-gradient(0, rgba(255,255,255,.07) 50%, transparent 50%),
  -webkit-linear-gradient(0, rgba(255,255,255,.13) 50%, transparent 50%),
  -webkit-linear-gradient(0, transparent 50%, rgba(255,255,255,.17) 50%),
  -webkit-linear-gradient(0, transparent 50%, rgba(255,255,255,.19) 50%);
-webkit-background-size: 13px, 29px, 37px, 53px;
}

body{
  @include cicada-stripes($background);
  padding:0;
  margin:0;
  } 

h1.logo{
  font-family: $logo-font;
  font-size: 48px;
  color:$logo-color;
  text-shadow: 1px 1px 1px rgba(#000,0.7);
  margin: 0;
  padding: 0;
  padding-left: 1em;
  float:left;
  }

.new-list{
  float:left;
  padding: 10px;
  input{
    border:#ccc 1px solid;
    border-radius: 16px;
    padding: 4px 8px;
    }
  .button{
    background:$orange;
    border:none;
    cursor: pointer;
    color: #fff;
    font-size: 24px;
    font-weight: bold;
    position: relative;
    left: -1em;
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
    color: transparent;
    padding:0 2px;
    border:solid 1px #ccc;
    cursor:pointer;
    }
  }

.tasks li.completed form.update input{
  color:$green;
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
  width:22%;
  margin:0 1%;
  padding: 0 1% 8px;
  border-top: solid 5px $green;
  background: rgba(#fff,0.6);
  padding-bottom: 20px;

  h1{  
    text-align:center;
    font-family:$heading-font;
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
    border: 1px solid #fff;
    color: #fff;
    border-radius:50%;
    font-size:16px;
    opacity:0.6;
    &:hover{
      opacity:1;
      background: #fff;
      color: $blue;
      }
    } 
  }
