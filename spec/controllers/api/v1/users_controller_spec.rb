require_relative '../../../../lib/crypto_wrapper/crypto_wrapper'
require "rails_helper"

describe Api::V1::UsersController, type: :controller do
  let(:user) {FactoryGirl.create(:user)}
  let(:requester) {Net::HTTP}

  describe "POST #check_login" do
    it "should verify received nonce" do
      logged_user = FactoryGirl.create(:user, nonce: 1, timestamp: DateTime.now)
      post :checklogin, id: logged_user.id, nonce: "IIDsuww5MjjtsYmk1UujxQ==", hmac: "XNUKC0/V7n87JnTuk441EQ=="
      expect(response.body).to eq({checklogin: "eiH+A6usMpOx3jGGELvVow==", hmac: "uDXr/In6K/n9PRkrGZJgGg=="}.to_json)
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
      expect(response.body).to eq({"nonce" => "OOfeDLXfP8DGJOcR5f5Txw==", "hmac" => "FAadyUsojpq5zC5l9i7/Zg=="}.to_json)
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
        expect(requester).to receive(:get_response).and_return(request_response)
        #post :redirect, id: 1, request: "{\"url\":\"http://en.wikipedia.org/wiki/Cassius_(band)\",\"method\":\"get\",\"id\":1,\"params\":{}}"
        post :redirect, id: user.id, hmac: "WsLhjwwJ/azPBllA2l7LIQ==", request: "XY5/3S5Zs8vrwL+8+uSKBVx4q9u3heOdAUdyKLpyARzNdC3vu9UEF3Fzpj+7aFq+2vHid9YbzpD4YedjCVaneSS/KPh1m47pP5/B4os5GmZqm+85+dG8uk5WKZjQx9eM"
        expect(user.reload.remaining_data).to eq 999
        expect(response.body.include? "response").to be
        expect(response.body.include? "hmac").to be
      end

      it "should return post request response" do
        expect(requester).to receive(:post_form).and_return(request_response)
        #post :redirect, id: user.id, request: "{\"url\":\"http://example.com/user\",\"method\":\"post\",\"id\":1,\"params\":{\"name\":\"Gui\",\"age\":23}}"
        post :redirect, id: user.id, hmac: "AVtimGijU7toC6mqhRpdhw==", request: "XY5/3S5Zs8vrwL+8+uSKBRLcP4rLiH58ip/OM1yqSN/Xb9ClkRfdQahf+Ziozal/6ZCD/GxsGkO77+KsKrbR2WvSgEkvCaRRYyOgyEXrAualpnWd3G83oHSO6cdlCY1y"
        expect(user.reload.remaining_data).to eq 999
        expect(response.body.include? "response").to be
        expect(response.body.include? "hmac").to be
      end
    end
  end
end
