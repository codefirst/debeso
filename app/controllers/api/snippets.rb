Debeso.controllers :"api/snippets" do

  get :index, :with => :id, :provides => :json do
    Snippet.where(:sha1_hash => params[:id]).first.to_json
  end

end
