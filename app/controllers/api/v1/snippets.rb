Debeso.controllers :"api/v1/snippets" do

  before do
    @repository_root = Setting[:repository_root]
  end

  get :index, :with => :id, :provides => [:json, :html] do
    @id = params[:id]
    @snippet = Snippet.where(:sha1_hash => @id).first
    open("#{@repository_root}/#{@id}.txt") {|f| @snippet.content = f.read}
    if params[:format] == 'html'
      render 'api/v1/index', :layout => false
    else params[:format] == 'json'
      unless @snippet.nil?
        @snippet.to_hash.to_json
      else
        {:message => "snippet #{@id} not found"}.to_json
      end
    end
  end

  get :show, :with => :id, :provides => :html do
    @id = params[:id]
    @snippet = Snippet.find_by_hash(@id)
    open("#{@repository_root}/#{@id}.txt") {|f| @snippet.content = f.read}
    render 'api/v1/show', :layout => false
  end

end
