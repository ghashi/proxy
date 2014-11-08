require 'net/http'

class Api::V1::UsersController < ApplicationController
  def redirect
    begin
      user = User.find(params[:id])
      return head :bad_request unless CryptoWrapper.verify_hmac(params[:hmac], params[:request], user.session_key)
      decrypted_params = get_decrypted_params user.session_key, params[:request]

      response = make_request_with decrypted_params
      update_remaining_data_of user, response

      encrypted_response = symmetric_encrypt(ActiveSupport::JSON.encode({remaining_data: user.remaining_data, content: response.body}), user.session_key)
      hmac = CryptoWrapper.get_hmac(user.session_key, encrypted_response)

      render json: {response: encrypted_response, hmac: hmac}
    rescue
      head :bad_request
    end
  end

  def login
    begin
      user = User.find(params[:id])

      formatted_params = {
       "url" => "#{ENV["AAAS_URL"]}/login",
       "method" => "POST",
       "params" => params
      }
      res = make_request_with formatted_params

      user.nonce = SecureRandom.hex(4)
      user.timestamp = DateTime.now
      user.session_key = res.body["session_key"]

      if user.save
        nonce = symmetric_encrypt(user.nonce, user.session_key)
        hmac = CryptoWrapper.get_hmac(user.session_key, nonce)
        render json: {nonce: nonce, hmac: hmac}
      else
        head :bad_request
      end
    rescue Exception => e
      puts e.message
      head :bad_request
    end
  end

  def checklogin
    begin
      user = User.find(params[:id])
      return head :bad_request unless CryptoWrapper.verify_hmac(params[:hmac], params[:nonce], user.session_key)
      encrypted_checklogin = checklogin_encrypted_value(params[:nonce], user.nonce, user.session_key)
      hmac = CryptoWrapper.get_hmac(user.session_key, encrypted_checklogin)
      render json: {checklogin: encrypted_checklogin, hmac: hmac}
    rescue Exception => e
      puts e.message
      head :bad_request
    end
  end

  private

  def checklogin_encrypted_value(expected_nonce, nonce, session_key)
    encrypted_nonce = symmetric_encrypt(nonce + 1, session_key)
    value = encrypted_nonce == expected_nonce ? "HANDSHAKE_OK" : "HANDSHAKE_FAILED"
    symmetric_encrypt(value, session_key)
  end

  def symmetric_encrypt(value, session_key)
    CryptoWrapper.symmetric_encrypt(value.to_s, session_key)
  end

  def get_decrypted_params(session_key, params)
    ActiveSupport::JSON.decode CryptoWrapper.symmetric_decrypt(session_key, params)
  end

  def make_request_with(decrypted_params)
    url = URI.parse(URI.encode(decrypted_params["url"]))
    if decrypted_params["method"].upcase == "GET"
      res = Net::HTTP.get_response(url)
    else
      res = Net::HTTP.post_form(url, decrypted_params["params"])
    end
    res
  end

  def update_remaining_data_of(user, response)
    used_data = Integer(response['Content-Length'])
    user.remaining_data -= used_data
    user.save
  end
end
