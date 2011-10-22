require 'spec_helper'

describe "Snippet Model" do
  let(:snippet) { Snippet.new }
  it 'can be created' do
    snippet.should_not be_nil
  end
end
