//
////  main.cpp
////  preClassifier
////
////  Created by Sabrina Kletz on 22.03.18.
////  Copyright © 2018 Sabrina Kletz. All rights reserved.
////
//
//#include <iostream>
//#include <fstream>
//
////caffe
//#include <caffe/caffe.hpp>
//
////opencv
//#include <opencv2/opencv.hpp>
//
////boost
//#include <boost/filesystem.hpp>
//#include <boost/range/iterator_range.hpp>
//#include <boost/program_options.hpp>
//
////logging
//#include <glog/logging.h>
//
////custom
//#include "classifier.hpp"
//#include "util.hpp"
//
//int main(int argc, const char * argv[]) {
//    
//    if (argc != 7) {
//        std::cerr << "Usage: " << argv[0]
//        << " deploy.prototxt network.caffemodel"
//        << " mean.binaryproto labels.txt ./videos ./output" << std::endl;
//        return 1;
//    }
//    
//    ::google::InitGoogleLogging(argv[0]);
//    
//    std::string model_file = argv[1];
//    std::string trained_file = argv[2];
//    std::string mean_file = argv[3];
//    std::string label_file = argv[4];
//    
//    Classifier classifier(model_file, trained_file, mean_file, label_file);
//    
//    std::string p = argv[5];
//    std::string output_dir = argv[6];
//    
//    if(boost::filesystem::is_directory(p))
//    {
//        std::cout << p << " is a directory containing: " << std::endl;
//        for(auto& entry : boost::make_iterator_range(boost::filesystem::directory_iterator(p), {}))
//        {
//            const boost::filesystem::path &file = entry;
//            if(!Util::isFileHidden(file))
//            {
//                std::cout << file << " " << std::endl;
//                
//                cv::VideoCapture stream(file.string());
//                if (!stream.isOpened())
//                {
//                    LOG(ERROR) << "Error: Video Stream cannot be opened: " << file;
//                }
//                
//                int framecnt = stream.get(CV_CAP_PROP_FRAME_COUNT);
//                int width = stream.get(CV_CAP_PROP_FRAME_WIDTH);
//                int height = stream.get(CV_CAP_PROP_FRAME_HEIGHT);
//                double fps = stream.get(CV_CAP_PROP_FPS);
//                
//                LOG(INFO) << "Length of input Video: " << framecnt;
//                //int curFrameNr = 0, prevFrameNr = 0;
//                cv::Mat frame, copyframe;
//
//                std::ofstream output;
//                boost::filesystem::path outp(output_dir);
//                std::string outputfilename = file.filename().string() + ".csv";
//                outp /= (outputfilename);
//                output.open(outp.string());
//                
//                if(!output.is_open())
//                    std::cerr << "Cannot open file: " << outp.string() << std::endl;
//                
//                output << "Videofile; ";
//                output << "Width; ";
//                output << "Height; ";
//                output << "Fps; ";
//                output << "Framecount; ";
//                output << "Framenr; ";
//                output << "Timecode; ";
//                output << "Label; ";
//                output << "Precision";
//                output << std::endl;
//
//                for (int iFrame = 0; iFrame < framecnt; iFrame++)
//                {
//                    stream.set(CV_CAP_PROP_POS_FRAMES, iFrame);
//                    stream.grab();
//                    stream.retrieve(frame);
//                    
//                    if (frame.empty())
//                        continue;
//                    
//                    double t = (double)cv::getTickCount();
//                    
//                    std::vector<Prediction> predictions = classifier.Classify(frame);
//                    
//                    t = ((double)cv::getTickCount() - t)/cv::getTickFrequency();
//                    std::cout << "Times passed in seconds: " << t << std::endl;
//                
//                    /* Print the top N predictions. */
//                    std::stringstream text;
//                    for (size_t i = 0; i < predictions.size(); ++i) {
//                        Prediction p = predictions[i];
//                        text << std::fixed << std::setprecision(4) << p.second << " - \"" << p.first << "\"" << "; ";
//                        
//                        output << file.filename().string() << "; ";
//                        output << width << "; ";
//                        output << height << "; ";
//                        output << framecnt << "; ";
//                        output << std::fixed << std::setprecision(10) << fps << "; ";
//                        output << iFrame << "; ";
//                        output << std::fixed << std::setprecision(4) << double(iFrame) / fps << "; ";
//                        output << p.first << "; ";
//                        output << std::fixed << std::setprecision(10) << p.second;
//                        output << std::endl;
//                    }
//                    
////                    frame.copyTo(copyframe);
////                    cv::putText(copyframe, text.str(), cv::Point(30,30), cv::FONT_HERSHEY_COMPLEX_SMALL, 0.8, cv::Scalar(200,200,250), 1, CV_AA);
////                    std::string name = "/Users/skletz/Dropbox/Programming/PLAYGround/preClassifier/testoutput/" + file.filename().string() + "_" + std::to_string(iFrame) + ".jpg";
////                    cv::imwrite(name, copyframe);
////                    cv::waitKey(0);
//                    frame.release();
////                    copyframe.release();
//                }
//                
//                output.close();
//            }
//        }
//        
//    }
//
////    std::cout << "---------- Prediction for " << "EMPTY" << " ----------" << std::endl;
////
////    cv::Mat img = cv::imread(file, -1);
////    CHECK(!img.empty()) << "Unable to decode image " << file;
////    std::vector<Prediction> predictions = classifier.Classify(img);
////
////    /* Print the top N predictions. */
////    for (size_t i = 0; i < predictions.size(); ++i) {
////        Prediction p = predictions[i];
////        std::cout << std::fixed << std::setprecision(4) << p.second << " - \""
////        << p.first << "\"" << std::endl;
////    }
//    
//    return 0;
//}

