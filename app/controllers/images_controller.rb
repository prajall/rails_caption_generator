class ImagesController < ApplicationController
  def create
    @image = Current.user.images.build
    @image.image.attach(params[:image])

    unless @image.save
      redirect_to root_path, alert: "Failed to upload image."
      return
    end

    begin
      service = GeminiCaptionService.new(@image)
      captions = service.generate_captions

      captions.each do |caption_text|
        @image.captions.create!(content: caption_text)
      end

      redirect_to root_path, notice: "Image uploaded and captions generated!"
    rescue StandardError => e
      Rails.logger.error("Caption generation failed: #{e.message}")
      redirect_to root_path, alert: "Image uploaded but caption generation failed: #{e.message}"
    end
  end
end
