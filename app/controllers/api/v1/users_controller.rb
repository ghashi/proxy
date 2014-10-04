require 'net/http'

class Api::V1::UsersController < ApplicationController
  def redirect
    data = params[:data]
    url = URI.parse(URI.encode(data[:url]))
    res = Net::HTTP.get_response(url)

    render html: res.body.html_safe
  end
end
