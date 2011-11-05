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
    @id = params[:id]
    @snippet = get_snippet(@id)
    render "codes/edit"
  end

  get :edit, :with => :id do
    @id = params[:id]
    @snippet = get_snippet(@id)
    if (not @snippet.repository_exist?) or (not @snippet.file_exist?(@id))
      flash[:error] = t(:this_content_is_no_longer_available)
      @snippet.destroy
      redirect url(:codes, :edit)
      return
    end
    render "codes/edit"
  end

  post :edit do
    @id = create_snippet
    file_name = params[:file_name]
    description = params[:description]
    content = params[:content] || ''
    @snippet = save_action(@id, file_name, description, content)
    redirect url(:codes, :edit, :id => @id)
  end

  post :edit, :with => :id do
    @id = params[:id]
    file_name = params[:file_name]
    description = params[:description]
    content = params[:content] || ''
    @snippet = save_action(@id, file_name, description, content)
    redirect url(:codes, :edit, :id => @id)
  end

  get :show_diff do
    # fake action for null id param
  end

  get :show_diff, :with => :id do
    @id = params[:id]
    @before_sha = params[:before]
    @after_sha = params[:after]
    if @before_sha.blank? or @after_sha.blank?
      flash[:warning] = t(:revisions_are_not_selected)
      redirect url(:codes, :edit, :id => @id)
      return
    end
    @snippet = Snippet.find_by_hash(@id)
    render "codes/show_diff"
  end

  get :search do
    @search_key = params[:search_key]
    if @search_key.blank?
      flash[:error] = "keyword empty"
      redirect url(:codes, :index)
      return
    end
    @search_result, ids = Snippet.search_from_repository(@repository_root, @search_key)
    @snippets = Snippet.search_from_db(@search_key, ids)
    render "codes/search"
  end

  get :show_snippet, :with => [:id, :commit] do
    @id = params[:id]
    @commit = params[:commit]
    @snippet = Snippet.find_by_hash(@id)
    render "codes/show_snippet"
  end
end
