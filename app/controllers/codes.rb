require 'digest/sha1'
require 'git'
Debeso.controllers :codes do

  include CodesHelper

  before do
    @repository_root = Setting[:repository_root]
  end

  get :index, :map => '/' do
    snippets = Arel::Table.new(:snippets)
    @snippets = Snippet.order(snippets[:updated_at].desc)
    render 'codes/index'
  end

  post :create_snippet do
    git = Git.init(@repository_root)
    id = Digest::SHA1.hexdigest(Time.now.to_s)
    # add "id_" to avoid implicit binary translation
    id = "id_" + id
    filename = "#{id}.txt"
    fullpath = "#{@repository_root}/#{filename}"
    open(fullpath, "w") {}
    snippet = Snippet.new(:sha1_hash => id, :created_at => Time.now, :updated_at => Time.now)
    snippet.save
    redirect url(:codes, :edit, :id => id)
  end

  get :edit, :with => :id do
    @id = params[:id]
    @commits = []
    unless @id.blank?
      @snippet = Snippet.where(:sha1_hash => @id).first
      git = Git.open(@repository_root)
      @commits = git.log.object("#{@id}.txt")
      file = "#{@repository_root}/#{@id}.txt"
      open(file) {|f| @content = f.read}
      @mode = ext2lang(@snippet.file_name.split(".")[-1]) unless @snippet.file_name.blank?
    end      
    render "codes/edit"
  end

  post :edit, :with => :id do
    @id = params[:id]
    @content = params[:content] || ""
    file_name = params[:file_name]
    description = params[:description]
    fullpath = @repository_root + "/#{@id}.txt"
    save_to_repository(@id, file_name, @content)
    save_snippet(@id, file_name, description, @content)
    redirect url(:codes, :edit, :id => @id)
  end

  get :show_diff, :with => :id do
    @id = params[:id]
    @before_sha = params[:before]
    @after_sha = params[:after]
    if @before_sha.blank? or @after_sha.blank?
      flash[:warning] = "revisions are not selected"
      redirect url(:codes, :edit, :id => @id)
      return
    end
    git = Git.open(@repository_root)
    @commits = git.log.object("#{@id}.txt")
    before_commit = git.gcommit(@before_sha)
    after_commit = git.gcommit(@after_sha)
    @diff = git.diff(before_commit, after_commit).path("#{@id}.txt")
    render "codes/show_diff"
  end

  get :search do
    @search_key = params[:search_key]
    if @search_key.blank?
      flash[:error] = "keyword empty"
      redirect url(:codes, :index)
      return
    end
    
    @search_result, ids = search_from_repository(@repository_root, @search_key)
    @snippets = search_from_db(@search_key, ids)

    render "codes/search"
  end

  get :show_snippet, :with => [:id, :commit] do
    @id = params[:id]
    @commit = params[:commit]
    git = Git.open(@repository_root)
    @commits = git.log.object("#{@id}.txt")
    @snippet = Snippet.where(:sha1_hash => @id).first
    @content = git.object(@commit + ":" + @id + ".txt").contents
    @mode = ext2lang(File.extname(@snippet.file_name))
    render "codes/show_snippet"
  end

end
