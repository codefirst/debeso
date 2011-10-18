require 'digest/sha1'
Debeso.controllers :codes do

  get :index, :map => '/' do
    @dirs = Dir.entries(Setting[:repository_root])
    @dirs.delete(".")
    @dirs.delete("..")
    render 'codes/index'
  end

  post :create_repository do
    Dir::mkdir(Setting[:repository_root] + "/" + Digest::SHA1.hexdigest(Time.now.to_s))
    redirect url(:codes, :index)
  end

end
