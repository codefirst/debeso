Debeso.controllers :"api/v1/snippets" do

  before do
    @repository_root = Setting[:repository_root]
  end

  get :index, :with => :id, :provides => [:json, :html] do
    @id = params[:id]
    @snippet = Snippet.find(@id)
    open("#{@repository_root}/#{@id}.txt") {|f| @snippet.content = f.read}
    unless @snippet.nil?
      if params[:format] == 'html'
        render 'api/v1/index', :layout => false
      elsif params[:format] == 'json'
        @snippet.to_hash.to_json
      else
        content_type 'text/plain'
        get_snippet(params[:id]).content
      end
    else
      {:message => "snippet #{@id} not found"}.to_json
    end
  end

  get :show, :with => :id, :provides => :html do
    @id = params[:id]
    @snippet = Snippet.find(@id)
    open("#{@repository_root}/#{@id}.txt") {|f| @snippet.content = f.read}
    render 'api/v1/show', :layout => false
  end

end
