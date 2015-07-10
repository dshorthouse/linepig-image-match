# encoding: utf-8
require 'find'
require 'ropencv'
include OpenCV

module Sinatra
  module Linepig
    module Match

      def execute_match(image)
        @image = image
        @descriptors_query = cv::Mat.new
        build_descriptors_query
        @similarities = find_matches
      end

      def build_descriptors_query
        detector = cv::Feature2D::create("SURF")
        mat_query = cv::imread(@image, cv::IMREAD_GRAYSCALE)
        keypoints_query = Std::Vector.new(cv::KeyPoint)
        detector.detect_and_compute(mat_query, mat_query, keypoints_query, @descriptors_query)
      end

      def find_matches
        descriptors_train = cv::Mat.new
        cvfile = cv::FileStorage.new(Sinatra::Application.settings.super_descriptor, cv::FileStorage::READ)
        cv::read_mat(cvfile["descriptors"], descriptors_train, descriptors_train)
        cvfile.release

        matcher = cv::DescriptorMatcher::create("FlannBased")
        matches = Std::Vector.new(cv::DMatch)
        matcher.match(@descriptors_query, descriptors_train, matches)

        similarities = {}
        index = YAML::load_file(Sinatra::Application.settings.super_descriptor_index)
        matches.each do |match|
          if match.distance < 0.2
            image = index.detect{|k,v| k === match.get_trainIdx}.last
            if similarities.has_key?(image)
              similarities[image] += 1
            else
              similarities[image] = 1
            end
          end
        end
        similarities.sort_by{|k,v| v}.reverse.first(10).to_h
      end
    
    end
  end
end