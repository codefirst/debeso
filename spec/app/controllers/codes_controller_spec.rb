require 'spec_helper'

describe "CodesController" do
  before do
    get "/"
  end

  it "returns hello world" do
    true.should be_true
  end
end
