require 'helper'

describe Reposlanger do
  describe ".data_path" do
    it "points to the data dir" do
      Reposlanger.data_path.split(File::SEPARATOR)[-1].should == "data"
    end
  end

  describe ".providers" do
    it "increments when a new provider is defined" do
      expect {
        class Reposlanger::TestProvider
          include Reposlanger::Provider
        end
      }.to change(Reposlanger.providers, :length).by(1)
      Reposlanger.providers["test_provider"].should eq Reposlanger::TestProvider
    end
  end
end