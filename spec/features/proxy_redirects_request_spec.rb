# coding: utf-8
require 'rails_helper'

describe "Proxy redirects request" do
  context "when user is present in the list of current users" do
    let(:user) {FactoryGirl.create(:user)}

    it "should return request response", js:true do
      visit get_path 'http://pt.wikipedia.org'
    end
  end
end
