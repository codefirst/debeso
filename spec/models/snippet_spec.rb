require 'spec_helper'

describe "Snippet Model" do
  before do
    @snippet = Snippet.new do |s|
      s.id = 1
      s.file_name = "hoge.rb"
      s.created_at = '2011/12/31'
      s.updated_at = '2012/1/15'
    end
  end
  it "to hash" do
    @snippet.to_hash[:id].should == 1
  end
end
