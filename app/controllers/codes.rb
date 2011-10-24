require 'digest/sha1'
require 'git'
Debeso.controllers :codes do

  get :index, :map => '/' do
    @snippets = Snippet.all
    render 'codes/index'
  end

  post :create_snippet do
    dir = Setting[:repository_root]
    git = Git.init(dir)
    snippet_name = params[:snippet_name]
    id = Digest::SHA1.hexdigest(Time.now.to_s)
    # add "id_" to avoid implicit binary translation
    id = "id_" + id
    filename = "#{id}.txt"
    fullpath = "#{dir}/#{filename}"
    open(fullpath, "w") {}
    git.add(fullpath)
    git.commit("add #{snippet_name}")
    snippet = Snippet.new(:sha1_hash => id, :file_name => snippet_name, :created_at => Time.now, :updated_at => Time.now)
    snippet.save
    redirect url(:codes, :edit, :id => id)
  end

  get :edit, :with => :id do
    @id = params[:id]
    @snippet = Snippet.where(:sha1_hash => @id).first
    dir = Setting[:repository_root]
    git = Git.open(dir)
    @commits = git.log.object("#{@id}.txt")
    file = "#{dir}/#{@id}.txt"
    open(file) {|f| @content = f.read}
    render "codes/edit"
  end

  post :edit, :with => :id do
    @id = params[:id]
    @content = params[:content]

    @snippet = Snippet.where(:sha1_hash => @id).first
    @snippet.description = params[:description]
    @snippet.updated_at = Time.now
    @snippet.save

    dir = Setting[:repository_root]
    file = dir + "/#{@id}.txt"

    if File.exists?(file)
      old_content = ""
      open(file) {|f| old_content = f.read}
    end

    unless old_content == @content
      open(file, "w") {|f| f.write(@content)}
      git = Git.open(dir)
      git.commit_all("update")
    end
    redirect url(:codes, :edit, :id => @id)
  end

  get :show_diff, :with => :repid do
    @id = params[:repid]
    @before_sha = params[:before]
    @after_sha = params[:after]
    dir = Setting[:repository_root]
    git = Git.open(dir)
    before_commit = git.gcommit(@before_sha)
    after_commit = git.gcommit(@after_sha)
    @diff = git.diff(before_commit, after_commit).path("#{@id}.txt")
    render "codes/show_diff"
  end

  post :search do
    @search_key = params[:search_key]
    dir = Setting[:repository_root]
    git = Git.open(dir)
    results = git.grep(@search_key, nil, :ignore_case => true)
    @search_result = {}
    ids = results.map do |key, value|
      id = key.split(":")[1]
      id = id.sub(File.extname(id), "")
      value.each do |result|
        @search_result[id] ||= {}
        @search_result[id][result[0].to_s] = result[1].to_s
      end
      id
    end
    snippets = Arel::Table.new(:snippets)
    @snippets = snippets.where(snippets[:sha1_hash].in(ids).or(snippets[:file_name].matches("%#{@search_key}%")).or(snippets[:description].matches("%#{@search_key}%"))).project(snippets[:sha1_hash], snippets[:file_name]).to_a
    render "codes/search"
  end

end
