# encoding: utf-8
require 'find'
require 'ropencv'
require 'byebug'
include OpenCV

module Linepig
  class DescriptorExtractor

    def initialize
      @detector = cv::Feature2D::create("SURF")
      @cvfile = cv::FileStorage.new(Sinatra::Application.settings.super_descriptor, cv::FileStorage::WRITE)
    end

    def create
      index = {}
      rows = 0
      super_descriptors = Std::Vector.new(cv::Mat)
      Find.find(Sinatra::Application.settings.image_library) do |file|
        next if !['.jpg', '.png'].include? File.extname(file)

        mat_train = cv::imread(file, cv::IMREAD_GRAYSCALE)
        keypoints_train = Std::Vector.new(cv::KeyPoint)
        descriptors_train = cv::Mat.new
        @detector.detect_and_compute(mat_train, mat_train, keypoints_train, descriptors_train)
        index_end = rows + descriptors_train.rows
        index[rows..index_end] = File.basename(file)
        puts File.basename(file) + " start:" + rows.to_s + " end:" + index_end.to_s
        rows += descriptors_train.rows
        super_descriptors.push_back(descriptors_train)
      end
      File.open(Sinatra::Application.settings.super_descriptor_index, "w") do |file|
        file.write index.to_yaml
      end
      descriptors = cv::Mat.new
      cv::vconcat(super_descriptors, descriptors)
      cv::write_mat(@cvfile, "descriptors", descriptors)
      @cvfile.release
    end
  
  end
end