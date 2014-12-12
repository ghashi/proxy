require 'net/http'
require_relative '../../../../lib/crypto_wrapper/crypto_wrapper.so'
require_relative '../../../../lib/services/get_ip'

class Api::V1::UsersController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def redirect
    begin
      user = User.find(params[:id])
      p params[:hmac]
      p params[:request]
      p user.session_key
      p CryptoWrapper.verify_hmac(params[:hmac], params[:request], user.session_key)
      return head :bad_request unless CryptoWrapper.verify_hmac(params[:hmac], params[:request], user.session_key)
      p "teste(((((((((((((((((((7"
      p params[:request]
      decrypted_params = get_decrypted_params user.session_key, params[:request]
      p "teste(((((((((((((((((((8"

      response = make_request_with decrypted_params
      update_remaining_data_of user, response
      encrypted_response = symmetric_encrypt(ActiveSupport::JSON.encode({remaining_data: user.remaining_data, content: Base64.encode64(response.body)}), user.session_key)
      #encrypted_response = (ActiveSupport::JSON.encode({remaining_data: user.remaining_data, content: Base64.encode64(response.body)}))
      hmac = CryptoWrapper.get_hmac(user.session_key, encrypted_response)

      p "teste(((((((((((((((((((9"
      render json: {response: encrypted_response, hmac: hmac}
    rescue  Exception => e
      p "DEU RUIM(((((((((((((((((((9"
      puts e.message
      p "DEU RUIM(((((((((((((((((((9"
      head :bad_request
    end
  end

  def login
    begin
      formatted_params = {
        "url" => "#{Rails.application.secrets["AAAS_URL"]}/login",
       "method" => "POST",
       "params" => params
      }

      res = make_request_with formatted_params
      res_json = ActiveSupport::JSON.decode(res.body)

      user = User.where(id: params[:id]).first_or_create
      user.name = res_json["cname"]
      user.next_hop = request.remote_ip
      user.ip = params[:supplicant] == "gateway" ? request.remote_ip : GetIp.call
      user.nonce = SecureRandom.hex(4).to_i
      user.timestamp = DateTime.now
      user.remaining_data = 10000000
      user.session_key = res_json["session_key"]

      if user.save
        nonce = symmetric_encrypt(user.nonce, user.session_key)
        hmac = CryptoWrapper.get_hmac(user.session_key, nonce)
        p "HAHAHAH"
        p "hmac " + hmac
        p "nonce " + nonce
        p "session_key " + user.session_key
        p CryptoWrapper.verify_hmac(hmac, nonce, user.session_key)
        render json: {nonce: nonce, hmac: hmac}
      else
        head :bad_request
      end
    rescue ActiveRecord::RecordNotFound => e
      puts "*****************************user not found"
      puts e.message
      render json: {error: "user not found"}
    rescue Exception => e
      puts e.message
      head :bad_request
    end
  end

  def checklogin
    begin
      user = User.find(params[:id])
      # TODO apagar comentário abaixo quando hmac estiver corrigido no android e no c
      p "*******************"
      p CryptoWrapper.verify_hmac(params[:hmac], params[:nonce], user.session_key)
      return head :bad_request unless CryptoWrapper.verify_hmac(params[:hmac], params[:nonce], user.session_key)
      p "CHECKLOGIN"
      p "params[nonce] " + params[:nonce]
      p "user.nonce " + user.nonce.to_s
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
    p "nonce + 1: " + (nonce + 1).to_s
    p "session_key: " + session_key
    p "decrypt expected_nonce: " + symmetric_decrypt(session_key, expected_nonce)

    encrypted_nonce = symmetric_encrypt((nonce + 1).to_s, session_key)
    p "encrypted user.nonce + 1: " + encrypted_nonce
    value = symmetric_decrypt(session_key, encrypted_nonce) == (nonce + 1).to_s ? "HANDSHAKE_OK" : "HANDSHAKE_FAILED"
    symmetric_encrypt(value, session_key)
  end

  def symmetric_encrypt(value, session_key)
    CryptoWrapper.symmetric_encrypt(value.to_s, session_key)
  end

  def symmetric_decrypt(session_key, value)
    CryptoWrapper.symmetric_decrypt(session_key, value)
  end

  def get_decrypted_params(session_key, params)
    decrypted_val = CryptoWrapper.symmetric_decrypt(session_key, params)
    p "dec value: " + decrypted_val
    ActiveSupport::JSON.decode decrypted_val 
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
