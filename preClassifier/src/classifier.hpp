//
//  classifier.hpp
//  preClassifier
//
//  Created by Sabrina Kletz on 22.03.18.
//  Copyright © 2018 Sabrina Kletz. All rights reserved.
//

#ifndef classifier_hpp
#define classifier_hpp

#include <string>
#include <memory> //shared pointers
#include <opencv2/opencv.hpp>
#include <caffe/caffe.hpp>
#include "util.hpp"

typedef std::pair<std::string, float> Prediction;

class Classifier
{
    
public:
    Classifier(const std::string& model_file, const std::string& trained_file, const std::string& mean_file, const std::string& label_file);
    
    std::vector<Prediction> Classify(const cv::Mat& img, int N = 9);
    
private:
    void SetMean(const std::string& mean_file);
    
    std::vector<float> Predict(const cv::Mat& img);
    
    /* Wrap the input layer of the network in separate cv::Mat objects
     * (one per channel). This way we save one memcpy operation and we
     * don't need to rely on cudaMemcpy2D. The last preprocessing
     * operation will write the separate channels directly to the input
     * layer.
     */
    void WrapInputLayer(std::vector<cv::Mat>* input_channels);
    
    void Preprocess(const cv::Mat& img, std::vector<cv::Mat>* input_channels);
    
private:
    std::shared_ptr<caffe::Net<float> > net_;
    cv::Size input_geometry_;
    int num_channels_;
    cv::Mat mean_;
    std::vector<std::string> labels_;
    
};

#endif /* classifier_hpp */
