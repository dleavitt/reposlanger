require 'helper'

describe String do
  describe "#underscore" do
    it "converts camelcase to underscores" do
      "TestCase".underscore.should == "test_case"
      "PigbotAB".underscore.should == "pi"
    end
  end
end