require 'digest/sha1'
require 'git'
Debeso.controllers :codes do

  get :index, :map => '/' do
    @snippets = Snippet.all
    render 'codes/index'
  end

  post :create_repository do
    id = Digest::SHA1.hexdigest(Time.now.to_s)
    dir = Setting[:repository_root] + "/" + id
    Dir::mkdir(dir)
    git = Git.init(dir)
    file = dir + "/file.txt"
    open(file, "w") {}
    git.add(file)
    git.commit("init")
    # add "id_" to avoid implicit binary translation
    snippet = Snippet.new(:sha1_hash => "id_" + id, :file_name => params[:snippet_name])
    snippet.save
    redirect url(:codes, :edit, :id => id)
  end

  get :edit, :with => :id do
    @id = params[:id]
    @snippet = Snippet.where(:sha1_hash => "id_" + @id).first
    dir = Setting[:repository_root] + "/" + @id
    git = Git.open(dir)
    @commits = git.log
    file = Setting[:repository_root] + "/" + @id + "/file.txt"
    open(file) {|f| @content = f.read}
    render "codes/edit"
  end

  post :edit, :with => :id do
    @id = params[:id]
    @content = params[:content]
    dir = Setting[:repository_root] + "/" + @id
    file = dir + "/file.txt"
    
    open(file, "w") {|f| f.write(@content)}
    git = Git.open(dir)
    git.commit_all("update")
    redirect url(:codes, :edit, :id => @id)
  end

  get :show_diff, :with => :repid do
    @id = params[:repid]
    @before_sha = params[:before]
    @after_sha = params[:after]
    dir = Setting[:repository_root] + "/" + @id
    git = Git.open(dir)
    before_commit = git.gcommit(@before_sha)
    after_commit = git.gcommit(@after_sha)
    @diff = git.diff(before_commit, after_commit)
    render "codes/show_diff"
  end

end
