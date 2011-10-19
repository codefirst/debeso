require 'digest/sha1'
require 'git'
Debeso.controllers :codes do

  get :index, :map => '/' do
    @dirs = Dir.entries(Setting[:repository_root])
    @dirs.delete(".")
    @dirs.delete("..")
    render 'codes/index'
  end

  post :create_repository do
    dir = Setting[:repository_root] + "/" + Digest::SHA1.hexdigest(Time.now.to_s)
    Dir::mkdir(dir)
    git = Git.init(dir)
    file = dir + "/file.txt"
    open(file, "w") {}
    git.add(file)
    git.commit("init")
    redirect url(:codes, :edit, :id => dir)
  end

  get :edit do
    render 'codes/edit'
  end

end
