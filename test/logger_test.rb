require File.expand_path("../test_helper", __FILE__)

describe LunaScanner::Logger do
  it "must have info method" do
    LunaScanner::Logger.must_respond_to(:info)
  end

  it "must have success method" do
    LunaScanner::Logger.must_respond_to(:success)
  end

  it "must have error method" do
    LunaScanner::Logger.must_respond_to(:error)
  end

end