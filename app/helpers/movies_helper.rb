module MoviesHelper
  def movie_poster_url(movie)
    return nil unless movie.poster.present?

    if movie.poster.include?(ImageProxyController::ALLOWED_HOST)
      image_proxy_path(url: movie.poster)
    else
      movie.poster
    end
  end
end
