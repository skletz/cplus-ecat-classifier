//
//  frameClassification.hpp
//  preClassifier
//
//  Created by Sabrina Kletz on 22.03.18.
//  Copyright © 2018 Sabrina Kletz. All rights reserved.
//

#ifndef frameClassification_hpp
#define frameClassification_hpp

#include <string>
#include <algorithm> //std::partial_sort
#include <vector>
#include <functional> //std::bind

#include <boost/filesystem.hpp>

class FrameClassification
{
    
public:
    
    std::string mModelFile;
    std::string mTrainedFile;
    std::string mMeanFile;
    std::string mLabelFile;
    
    FrameClassification(std::string _modelFile, std::string _trainedFile, std::string _meanFile, std::string _labelFile);
    
    /**
     * Run frame classification on a given input directory, containing video files
     */
    void run(std::string _inputDir, std::string _outputDir);
    
private:
    
};

#endif /* frameClassification.hpp */
