require 'spec_helper'

describe "Api::SnippetsController" do
  before do
    get "/"
  end

  it "returns hello world" do
    last_response.body.should_not be_nil 
  end
end
