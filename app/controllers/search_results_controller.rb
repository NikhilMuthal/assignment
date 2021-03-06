require 'will_paginate/array'
require 'httparty'
class SearchResultsController < ApplicationController
  include HTTParty
  
  def index
  end

  def search
    
    begin
      @paginate = true
      fetch_results
    rescue
      flash[:notice] = "Error"
    end
    
  end
  
  def  export_to_pdf
    begin
      @paginate = false
      fetch_results
      html = render_to_string(:file =>"#{Rails.root}/app/views/search_results/_search_results.html.erb", :layout => false)
      pdf = PDFKit.new(html)
      send_data(pdf.to_pdf)
    rescue
      flash[:notice] = "Error"
    end
    
  end
  
  def fetch_results
    begin
      search_query = params[:search]
      get_github_user(search_query)
      ruby_gems_owners(search_query)
      twitter_news(search_query)
    rescue
      flash[:notice] = "Error"
    end
    
  end
 
  def get_github_user(search)
    begin
      client = Octokit::Client.new \
        :client_id     => "45a9c303eb9268a6725b",
        :client_secret => "3deda5c5f76040b2837517d4529e2c8f18776d6c"
    
      @user = client.user search 
      @repos = @user.rels[:repos].get.data
      @created_at = @user.created_at
      @repos = @repos.paginate(:page => params[:github_page], :per_page => 10) if @paginate
    rescue
      flash[:notice] = "Error"
    end  
    
  end
    
  def ruby_gems_owners(search)
    begin
      base_uri = "https://rubygems.org/api/v1/owners/#{search}/gems.json"
      @response = HTTParty.get("#{base_uri}").parsed_response
      @response = @response.paginate(:page => params[:rubyGems_page], :per_page => 10) if @paginate
  
    rescue
      flash[:notice] = "Error"
    end
    
  end

  def twitter_news(search)
    begin
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = "UblzqTDa7NvGjN0MZZs1wDSgY"
        config.consumer_secret     = "E0e33TiG3TcZ6BMeWEFTleZcz1hczAxWWOLwmuhAZ3j0sIEeEV"
        config.access_token        = "197863336-d7GOniO5X0X82k8jFezRGRLYLvJ5g3ePfGiWRNKO"
        config.access_token_secret = "DVz7LzygKsBm1fOcWZURaW8LO6LLa6SkSYnPEDG2jir2m"
      end
      @twitter_user = client.user_timeline(search, :count => 10)
      @twitter_user = @twitter_user.paginate(:page => params[:twitter_page], :per_page => 10) if @paginate
    rescue
      flash[:notice] = "Error"
    end
  end

  
end
