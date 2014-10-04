require "rails_helper"

describe Api::V1::UsersController, type: :controller do
  describe "POST #redirect" do
    context "when user is present in the list of current users" do
      let(:user) {FactoryGirl.create(:user)}
      let(:requester) {Net::HTTP}
      let(:request_response) do
        Struct.new("Response", :body)
        Struct::Response.new("body response")
      end

      it "should return get request response" do
        expect(requester).to receive(:get_response).with(URI.parse("http://en.wikipedia.org/wiki/Cassius_(band)")).and_return(request_response)
        post :redirect, data: {url: "http://en.wikipedia.org/wiki/Cassius_(band)"}
      end
    end
  end
end
