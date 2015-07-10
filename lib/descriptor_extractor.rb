# encoding: utf-8
require 'find'
require 'ropencv'
require 'byebug'
include OpenCV

module Linepig
  class DescriptorExtractor

    def initialize
      @detector = cv::Feature2D::create("SURF")
    end

    def create
      Find.find(Sinatra::Application.settings.image_library) do |file|
        next if !['.jpg', '.png'].include? File.extname(file)

        file_name = File.basename(file, File.extname(file))
        file_name.gsub!(/[^0-9A-Za-z]/, '_')

        mat_train = cv::imread(file, cv::IMREAD_GRAYSCALE)
        keypoints_train = Std::Vector.new(cv::KeyPoint)
        descriptors_train = cv::Mat.new
        @detector.detect_and_compute(mat_train, mat_train, keypoints_train, descriptors_train)

        cvfile = cv::FileStorage.new(Sinatra::Application.settings.descriptor_store + file_name + ".yml", cv::FileStorage::WRITE)
        cv::write_string(cvfile, "src", file)
        cv::write_mat(cvfile, "descriptors", descriptors_train)
        cvfile.release
        puts "Built descriptors for #{file}"
      end
    end
  
  end
end