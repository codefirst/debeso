require 'spec_helper'

describe "Snippet Model" do
  before do
    @snippet = Snippet.new do |s|
      s.id = 1
      s.file_name = "hoge.rb"
      s.created_at = '2011/12/31'
      s.updated_at = '2012/1/15'
    end

    @git = mock()
    @blob = mock()
    @git.stub(:object) { @blob }
    @blob.stub(:contents) { "print 'hoge'" }
    Git.stub(:open) { @git }

  end

  subject { @snippet }
  its(:mime) { should == 'text/x-ruby' }
  its(:mode) { should == 'ruby' }

  context "use repository" do
    before do
      File.stub(:exist?) { true }
    end
    context "to_hash" do
      subject { @snippet.to_hash }
      its([:id]) { should == 1 }
      its([:name]) { should == "hoge.rb" }
      its([:content]) { should == "print 'hoge'" }
    end

    context "search_from_repository" do
      before do
        @git.stub(:grep) { {"abcdef12345:1.txt"=>[[1, "print 'hoge'"]]} }
      end
      subject { Snippet.search_from_repository('/path/to/repo', 'hoge') }
      its([0]) { should == {"1" => { 1 => "print 'hoge'"} } }
      its([1]) { should == ["1"] }
    end

    context "get commits" do
      before do
        @commit1 = mock()
        @commit2 = mock()
        @log = mock()
        @tree = mock()
        @diff = mock()
        @log.stub(:object) { [@commit1, @commit2] }
        @git.stub(:log) { @log }
        @tree.stub(:path) { @diff }
        @git.stub(:diff).with(@commit1, @commit2) { @tree }
      end
      its(:commits) { should == [@commit1, @commit2] }
      context "get diff" do
        subject { @snippet.diff(@commit1, @commit2) }
        it { should == @diff }
      end
    end

    context "delete" do
      before do
        File.stub(:delete) {}
        @git.stub(:commit_all) {}
        @snippet.stub(:delete) { true }
      end
      subject { @snippet.delete_file(1) }
      it { should be_true }
    end

    context "get language from extension" do
      subject { @snippet.ext2lang(".rb") }
      it { should == ["ruby", "text/x-ruby"] }
    end
  end
end
