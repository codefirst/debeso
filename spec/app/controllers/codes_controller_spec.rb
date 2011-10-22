require 'spec_helper'

describe "CodesController" do
  before do
    get "/"
  end

  it "be true" do
    true.should be_true
  end
end
