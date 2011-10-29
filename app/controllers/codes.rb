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

  get :edit do
    edit_action
    render "codes/edit"
  end

  get :edit, :with => :id do
    edit_action
    render "codes/edit"
  end

  post :edit do
    @id = create_snippet
    save_action
  end

  post :edit, :with => :id do
    @id = params[:id]
    save_action
  end

  get :show_diff do
    # fake action for null id param
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
