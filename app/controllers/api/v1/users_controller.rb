require 'net/http'

class Api::V1::UsersController < ApplicationController
  def redirect
    begin
      user = User.find(params[:id])
      decrypted_params = get_decrypted_params user.session_key, params
      response = make_request_with decrypted_params
      update_remaining_data_of user, response

      render json: json_of(response, user)
    rescue
      head :bad_request
    end
  end

  private

  def get_decrypted_params(session_key, params)
      Decrypt.call(session_key, params)
  end

  def make_request_with(decrypted_params)
    url = URI.parse(URI.encode(decrypted_params[:url]))
    if decrypted_params[:method].upcase == "GET"
      res = Net::HTTP.get_response(url)
    else
      res = Net::HTTP.post_form(url, decrypted_params[:params])
    end
    res
  end

  def update_remaining_data_of(user, response)
    used_data = Integer(response['Content-Length'])
    user.remaining_data -= used_data
    user.save
  end

  def json_of(response, user)
    {remaining_data: user.remaining_data,
     content: response.body}
  end
end
