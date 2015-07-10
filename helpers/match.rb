# encoding: utf-8

module Sinatra
  module Linepig
    module Match

      def execute_match(image)
        @image = image
        build_descriptors_query
        @matches = find_matches.sort_by{|v| v[:score]}.reverse.first(10)
      end

      def build_descriptors_query
        detector = cv::Feature2D::create("SURF")
        mat_query = cv::imread(@image, cv::IMREAD_GRAYSCALE)
        keypoints_query = Std::Vector.new(cv::KeyPoint)
        @descriptors_query = cv::Mat.new
        detector.detect_and_compute(mat_query, mat_query, keypoints_query, @descriptors_query)
      end

      def find_matches
        match_results = []
        matcher = cv::DescriptorMatcher::create("FlannBased")
        Find.find(Sinatra::Application.settings.descriptor_store) do |file|
          next if !['.yml'].include? File.extname(file)

          file_name = File.basename(file, File.extname(file))
          file_name.gsub!(/[^0-9A-Za-z]/, '_')

          cvfile = cv::FileStorage.new(file, cv::FileStorage::READ)

          raw_src = cv::String.new
          descriptors_train = cv::Mat.new
          cv::read_string(cvfile["src"], raw_src, raw_src)
          cv::read_mat(cvfile["descriptors"], descriptors_train, descriptors_train)
          cvfile.release

          matches = Std::Vector.new(cv::DMatch)
          matcher.match(@descriptors_query, descriptors_train, matches)

          good_match_size = matches.find_all{|match| match.distance < 0.2}.size

          if good_match_size > 10
            match_results << {image_src: raw_src.to_s, score: good_match_size}
          end
        end
        match_results
      end
    
    end
  end
end