require 'net/http'

class RedirectController < ApplicationController
  def get
    url = URI.parse(URI.encode(params[:site]))
    res = Net::HTTP.get_response(url)

    render html: res.body.html_safe
  end
end
