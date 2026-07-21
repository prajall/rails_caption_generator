class HomeController < ApplicationController
  def index
    @images = Current.user.images.includes(:captions).with_attached_image.order(created_at: :desc)
  end
end
