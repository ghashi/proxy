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
    let(:login_user) {FactoryGirl.create(:user, :session_key => "1")}
    let!(:request_response) do
      response = {}
      def response.body
        {"session_key" => "AAECAwQFBgcICQoLDA0ODw=="}
      end
      response
    end

    it "should redirect the login request and answer with e(n)" do
      allow(SecureRandom).to receive(:hex).and_return(7)
      expect(requester).to receive(:post_form).and_return(request_response)
      post :login, id: login_user.id
      expect(login_user.reload.nonce).to eq 7
      expect(response.body).to eq({"nonce" => "OOfeDLXfP8DGJOcR5f5Txw=="}.to_json)
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
        #post :redirect, url: "http://en.wikipedia.org/wiki/Cassius_(band)", method: "get" , id: user.id, params: {}
        post :redirect, id: user.id, msg: "8ZQ76jsSKr5V+fgvhIpSvH9OR83BF159bj3lTRlkyFV/Ax1Aq52F+f5q2usxVzKlBBmVIJ2f6ZSIlEXYOY9SdA=="
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
