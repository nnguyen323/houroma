# encoding: utf-8

class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process resize_to_limit: [500,500]
  version :thumb do
    process resize_to_fill: [120,120]
  end
  version :activity do
    process resize_to_limit: [200,200]
  end
  version :thumb_small do
    process resize_to_fill: [50,50]
  end
  version :thumb_tiny do
    process resize_to_fill: [20,20]
  end

  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end


  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
