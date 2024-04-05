require 'nokogiri'
require 'open-uri'
class ScrapeDetailsController < ApplicationController

  def product_details
    @products = params[:category].present? ? Product.where(category: params[:category]) : Product.all
  end
  
  def scrape
    url = params[:product_url]
    doc = Nokogiri::HTML(URI.open(url))

    title = doc.css('#productTitle').text.strip
    description = doc.css('#productDescription').text.strip
    # size = doc.css('div div p span').text.strip
    price = doc.at_css('.a-price-whole').text.gsub(/[^\d]/, '').strip.to_f
    category = doc.at_css('//*[@id="wayfinding-breadcrumbs_feature_div"]/ul/li[1]/span/a').text.strip
    # contact_info = doc.css('div div p span').text.strip
    
    Product.create do |p|
      p.url = url
      p.title = title
      p.description = description
      p.category = category
      p.price = price
    end

    redirect_to product_details_path
  end

  def search_product
    @products = params[:search_input].present? ? Product.where("title iLIKE ?", "%#{params[:search_input]}%") : Product.all
    render partial: "scrape_details/product_list"
  end
end