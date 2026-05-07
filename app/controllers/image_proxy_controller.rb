class ImageProxyController < ApplicationController
  ALLOWED_HOST = "film-cdn.moviexchange.com"

  def show
    url = params[:url]
    uri = URI.parse(url)

    unless uri.host == ALLOWED_HOST
      head :forbidden and return
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    request = Net::HTTP::Get.new(uri.request_uri, {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      "Referer" => "https://www.cinesa.es/",
      "Accept" => "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
      "Accept-Language" => "es-ES,es;q=0.9"
    })

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("ImageProxy CDN error: #{response.code} #{response.message} body=#{response.body.first(200)}")
      head :bad_gateway and return
    end

    content_type = response["Content-Type"] || "image/jpeg"
    send_data response.body, type: content_type, disposition: "inline"
  rescue URI::InvalidURIError
    head :bad_request
  end
end
