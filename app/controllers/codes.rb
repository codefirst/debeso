Debeso.controllers :codes do

  get :index, :map => '/' do
    @dirs = Dir.entries(Setting[:repository_root])
    @dirs.delete(".")
    @dirs.delete("..")
    render 'codes/index'
  end

end
