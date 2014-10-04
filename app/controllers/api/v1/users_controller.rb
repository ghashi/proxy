require 'net/http'

class Api::V1::UsersController < ApplicationController
  def redirect
    url = URI.parse(URI.encode(params[:url]))
    if params[:method].upcase == "GET"
      res = Net::HTTP.get_response(url)
    else
      res = Net::HTTP.post_form(url, params[:params])
    end

    puts res['Content-Length']

    render html: res.body.html_safe
  end
end
