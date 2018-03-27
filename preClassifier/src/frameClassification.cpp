#include "frameClassification.hpp"

#include "classifier.hpp"
#include "util.hpp"

#include <iostream>
#include <fstream>
#include <opencv2/opencv.hpp>
#include <boost/filesystem.hpp>
#include <boost/range/iterator_range.hpp>
#include <glog/logging.h>


FrameClassification::FrameClassification(std::string _modelFile, std::string _trainedFile, std::string _meanFile, std::string _labelFile){
    this->mModelFile = _modelFile;
    this->mTrainedFile = _trainedFile;
    this->mMeanFile = _meanFile;
    this->mLabelFile = _labelFile;
}

void FrameClassification::run(std::string _inputDir, std::string _outputDir)
{
    Classifier classifier(this->mModelFile, this->mTrainedFile, this->mMeanFile, this->mLabelFile);
    DLOG(INFO) << "Classifier initialized ..." << std::endl;
    
    int fileCount = 0;
    //Count video files for progress bar
    for(auto& entry : boost::make_iterator_range(boost::filesystem::directory_iterator(_inputDir), {}))
        if(!Util::isFileHidden(entry))
            fileCount++;
    
    LOG(INFO) << "Number of video files: " << fileCount;
    
    //Process video files
    if(boost::filesystem::is_directory(_inputDir))
    {
        int fileCounter = 0;
        DLOG(INFO) << "Process input directory: " << _inputDir << std::endl;
        for(auto& entry : boost::make_iterator_range(boost::filesystem::directory_iterator(_inputDir), {}))
        {
            const boost::filesystem::path &file = entry;
            if(!Util::isFileHidden(file))
            {
               
                cv::VideoCapture stream(file.string());
                if (!stream.isOpened())
                {
                    LOG(ERROR) << "Error: Video Stream cannot be opened: " << file;
                }
                
                int frameCount = stream.get(CV_CAP_PROP_FRAME_COUNT);
                int width = stream.get(CV_CAP_PROP_FRAME_WIDTH);
                int height = stream.get(CV_CAP_PROP_FRAME_HEIGHT);
                double fps = stream.get(CV_CAP_PROP_FPS);
                
                LOG(INFO) << file.filename().string() << ": Number of frames: " << frameCount;
                cv::Mat frame;
                
                std::ofstream output;
                boost::filesystem::path outp(_outputDir);
                std::string outputfilename = file.filename().string() + ".csv";
                outp /= (outputfilename);
                output.open(outp.string());
                
                if(!output.is_open())
                    LOG(ERROR) << "Cannot open file: " << outp.string() << std::endl;
                
                output << "Videofile; ";
                output << "Width; ";
                output << "Height; ";
                output << "Fps; ";
                output << "Framecount; ";
                output << "Framenr; ";
                output << "Timecode; ";
                output << "Label; ";
                output << "Precision";
                output << std::endl;
                
                double elapsedTime = 0.0;
                for (int iFrame = 0; iFrame < frameCount; iFrame++)
                {
                    Util::showProgress(file.filename().string() + ": Processed frames", iFrame + 1, frameCount);
                    
                    stream.set(CV_CAP_PROP_POS_FRAMES, iFrame);
                    stream.grab();
                    stream.retrieve(frame);

                    if (frame.empty())
                        continue;

                    double t = (double)cv::getTickCount();

                    std::vector<Prediction> predictions = classifier.Classify(frame);

                    t = ((double)cv::getTickCount() - t)/cv::getTickFrequency();
                    elapsedTime += t;


                    /* Print the top N predictions. */
                    std::stringstream text;
                    for (size_t i = 0; i < predictions.size(); ++i) {
                        Prediction p = predictions[i];
                        text << std::fixed << std::setprecision(4) << p.second << " - \"" << p.first << "\"" << "; ";

                        output << file.filename().string() << "; ";
                        output << width << "; ";
                        output << height << "; ";
                        output << frameCount << "; ";
                        output << std::fixed << std::setprecision(10) << fps << "; ";
                        output << iFrame << "; ";
                        output << std::fixed << std::setprecision(4) << double(iFrame) / fps << "; ";
                        output << p.first << "; ";
                        output << std::fixed << std::setprecision(10) << p.second;
                        output << std::endl;
                    }

                    frame.release();
                }
                
                LOG(INFO) << "Average time passed for classification in seconds: " << elapsedTime / double(frameCount) << std::endl;
                output.close();
                stream.release();
                Util::showProgress("Processed videos", fileCounter + 1, fileCount);
                fileCounter++;
            }
        }
        
    }
}
