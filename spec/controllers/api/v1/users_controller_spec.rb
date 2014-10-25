require_relative '../../../../lib/crypto_wrapper/crypto_wrapper'
require "rails_helper"

describe Api::V1::UsersController, type: :controller do
  let(:user) {FactoryGirl.create(:user)}
  let(:requester) {Net::HTTP}

  describe "POST #check_login" do
    it "should verify received nonce" do
      allow(CryptoWrapper).to receive(:encrypt).and_return("2")
      logged_user = FactoryGirl.create(:user, nonce: 1, timestamp: DateTime.now)
      post :checklogin, id: logged_user.id, nonce: "2"
      expect(response.body).to eq({checklogin: true}.to_json)
    end
  end

  describe "POST #login" do
    let(:request_response) do
      response = {}
      def response.body
        {"session_key" => "session_key"}.to_json
      end
      response
    end

    it "should redirect the login request and answer with e(n)" do
      allow(CryptoWrapper).to receive(:encrypt).and_return(1)
      expect(requester).to receive(:post_form).and_return(request_response)
      post :login, id: user.id
      expect(user.reload.session_key).to eq "session_key"
      expect(response.body).to eq({"nonce" => 1}.to_json)
    end

    it "should redirect the login request and answer with e(n)" do
      post :login
      expect(response.status).to eq 400
    end
  end

  describe "POST #redirect" do
    context "when user is present in the list of current users" do
      let(:request_response) do
        response = {"Content-Length" => "1"}
        def response.body
          "body response"
        end
        response
      end

      it "should return get request response" do
        expect(requester).to receive(:get_response).with(URI.parse("http://en.wikipedia.org/wiki/Cassius_(band)")).and_return(request_response)
        post :redirect, url: "http://en.wikipedia.org/wiki/Cassius_(band)", method: "get" , id: user.id, params: {}
        expect(user.reload.remaining_data).to eq 999
      end

      it "should return post request response" do
        expect(requester).to receive(:post_form).with(URI.parse("http://example.com/user"), {"name" => "Gui", "age" => "23"}).and_return(request_response)
        post :redirect, url: "http://example.com/user", method: "post", id: user.id, params:{name: "Gui", age: 23}
        expect(user.reload.remaining_data).to eq 999
      end
    end
  end
end
