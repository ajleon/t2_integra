require "http"
require "json"

class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def buscar

    tag = params[:tag]

    access_token = params[:access_token]

    tag_search = JSON.parse(HTTP.headers(:"Content-Type" => "application/json").get("https://api.instagram.com/v1/tags/search?q="+tag+"&access_token="+access_token).to_s, :symbolize_names => true)



    media = JSON.parse(HTTP.headers(:"Content-Type" => "application/json").get("https://api.instagram.com/v1/tags/"+tag+"/media/recent?access_token="+access_token).to_s, :symbolize_names => true)

    posts = []

    media[:data].each do |media_found|


      tags = []

      media_found[:tags].each do |tag|

        tags.push(tag)

      end

      if media_found[:type] == "video"
        url = media_found[:videos][:standard_resolution][:url]
      else
        url = media_found[:images][:standard_resolution][:url]
      end
      post = {:tags => tag,:username=> media_found[:user][:username], :likes=> media_found[:likes][:count], :url => url, :caption => media_found[:caption][:text]}

      posts.push(post)
    end

    count =0
    tag_search[:data].each do |tag_count|


      count += tag_count[:media_count]
    end



    response = { :metadata => { :total => count}, :posts => posts,:version=> "1.1.1"}
    render :json => response
  end


end
