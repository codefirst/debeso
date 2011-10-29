Debeso.controllers :"api/v1/snippets" do

  before do
    @repository_root = Setting[:repository_root]
  end

  get :index, :with => :id, :provides => :json do
    id = params[:id]
    snippet = Snippet.where(:sha1_hash => id).first
    unless snippet.nil?
      open("#{@repository_root}/#{id}.txt") {|f| snippet.content = f.read}
      snippet.to_hash.to_json
    else
      {:message => "snippet #{id} not found"}.to_json
    end
  end

end
