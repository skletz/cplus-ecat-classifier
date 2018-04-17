//
//  main.cpp
//  preClassifier
//
//  Created by Sabrina Kletz on 22.03.18.
//  Copyright © 2018 Sabrina Kletz. All rights reserved.
//

#include <iostream>
#include <boost/program_options.hpp>
#include <glog/logging.h>
#include "frameClassification.hpp"

boost::program_options::variables_map processProgramOptions(const int argc, const char *const argv[]);
bool init(boost::program_options::variables_map _args);
std::string help(const boost::program_options::options_description& _desc);

//Program Options
std::string programName = "";
bool verbose = false;
bool display = false;
std::string inputDir;
std::string outputDir;
std::string model;
std::string trainedModel;
std::string mean;
std::string labels;

int main(int argc, const char * argv[]) {
    
    //Initialize Google's logging library
    google::InitGoogleLogging(argv[0]);
    
    DLOG(INFO) << "Process started ..." << std::endl;
    
    boost::program_options::variables_map args;
    
    try
    {
        args = processProgramOptions(argc, argv);
        programName = argv[0];
    }
    catch (std::exception& e)
    {
        LOG(ERROR) << "ERROR: Programm options cannot be used!" << std::endl;
        LOG(ERROR) << e.what() << std::endl;
    }
    
    bool isValid = init(args);
    
    if(!isValid){
        LOG(ERROR) << "ERROR: Some arguments are not valid!" << std::endl;
        return EXIT_FAILURE;
    }
    
    FrameClassification* frameClassifiaction = new FrameClassification(model, trainedModel, mean, labels);
    frameClassifiaction->run(inputDir, outputDir);
    delete frameClassifiaction;
    
    DLOG(INFO) << "Process finished ..." << std::endl;
    return EXIT_SUCCESS;
}

std::string help(const boost::program_options::options_description& _desc)
{
    std::stringstream help;
    
    help << "============== Help ==============" << std::endl;
    help << "INFO: This program classifies each frame individual of a given video directory and stores the predictions for each video file into a CSV file ..." << std::endl;
    help << "INFO: Call ./main --input [path] --output [path] --model [path] --trained [path] --mean [path] --labels [path]" << std::endl;
    help << "============== Help ==============" << std::endl;
    help << _desc << std::endl;
    return help.str();
}

bool init(boost::program_options::variables_map _args){
    
    bool areArgumentsValid = true;
    
    if(verbose)
        std::cout << "Initialize cvSketch parameter ..." << std::endl;
    
    if (_args.find("verbose") != _args.end())
    {
        verbose = true;
    }
    
    if (_args.find("display") != _args.end())
    {
        display = true;
    }
    
    if(_args.find("input") != _args.end()){
        inputDir = _args["input"].as<std::string>();
    }
    
    if(_args.find("output") != _args.end()){
        outputDir = _args["output"].as<std::string>();
    }
    
    if(_args.find("model") != _args.end()){
        model = _args["model"].as<std::string>();
    }
    
    if(_args.find("mean") != _args.end()){
        mean = _args["mean"].as<std::string>();
    }
    
    if(_args.find("trained") != _args.end()){
        trainedModel = _args["trained"].as<std::string>();
    }
    
    if(_args.find("labels") != _args.end()){
        labels = _args["labels"].as<std::string>();
    }
    
    if (!boost::filesystem::is_directory(inputDir)) {
        LOG(ERROR) << "Input Directory: " <<  ((inputDir == "") ? "<No Parameter given>" : inputDir) << " does not exit." << std::endl;
        areArgumentsValid = false;
    }
    
    if(!boost::filesystem::exists(model)){
        LOG(ERROR) << "Model File: " <<  ((model == "") ? "<No Parameter given>" : model) << " does not exit." << std::endl;
        areArgumentsValid = false;
    }
    
    if(!boost::filesystem::exists(trainedModel)){
        LOG(ERROR) << "Trained Model File: " << ((trainedModel == "") ? "<No Parameter given>" : trainedModel) << " does not exit." << std::endl;
        areArgumentsValid = false;
    }
    
    if(!boost::filesystem::exists(mean)){
        LOG(ERROR) << "Mean File: " << ((mean == "") ? "<No Parameter given>" : mean) << " does not exit." << std::endl;
        areArgumentsValid = false;
    }
    
    if(!boost::filesystem::exists(labels)){
        LOG(ERROR) << "Labels File: " <<  ((labels == "") ? "<No Parameter given>" : labels) << " does not exit." << std::endl;
        areArgumentsValid = false;
    }
    
    if (!boost::filesystem::is_directory(outputDir)) {
        bool successful = boost::filesystem::create_directory(outputDir);
        if(successful){
            LOG(ERROR) << "Cannot create: " << outputDir << std::endl;
            areArgumentsValid = false;
        }
    }
    
    //ToDo check if all parameters are valid, otherwise abort
    LOG(INFO) << "Initialized Arguments: " << std::endl;
    LOG(INFO) << "--input: " << inputDir << std::endl;
    LOG(INFO) << "--output: " << outputDir << std::endl;
    LOG(INFO) << "--model: " << model << std::endl;
    LOG(INFO) << "--trainedModel: " << trainedModel << std::endl;
    LOG(INFO) << "--mean: " << mean << std::endl;
    LOG(INFO) << "--labels: " << labels << std::endl;
    LOG(INFO) << "--verbose: " << verbose << std::endl;
    LOG(INFO) << "--display: " << display << std::endl;
    
    return areArgumentsValid;
}

boost::program_options::variables_map processProgramOptions(const int argc, const char *const argv[]){
    boost::program_options::options_description generic("Generic options");
    generic.add_options()
    ("help,h", "Print options")
    ("verbose", "show additional information while processing (default false)")
    ("display", "display output while processing (default false)")
    ("input", boost::program_options::value<std::string>(), "the videos to process (directory of videos ./input)")
    ("output", boost::program_options::value<std::string>()->default_value("output"), "specify the output (default is ./output/input1.csv,input2.csv)")
    ("model", boost::program_options::value<std::string>(), "the model (./deploy.prototxt)")
    ("trained", boost::program_options::value<std::string>(), "the trained model (./snapshot.caffemodel)")
    ("mean", boost::program_options::value<std::string>(), "the mean (./mean.binaryproto)")
    ("labels", boost::program_options::value<std::string>(), "the labels (labels.txt)")
    ;
    
    boost::program_options::options_description visible("Allowed options");
    visible.add(generic);
    
    if(argc < 6)
        LOG(ERROR) << "Too few arguments!: " << help(visible);
    
    boost::program_options::variables_map args;
    
    try
    {
        store(boost::program_options::command_line_parser(argc, argv).options(generic).run(), args);
    }
    catch (boost::program_options::error const& e)
    {
        LOG(ERROR) << "ERROR in Processing program options ..." << std::endl;
        
        LOG(ERROR) << e.what() << std::endl;
        LOG(ERROR) << help(visible) << std::endl;
    }
    
    if (args.count("help")) {
        LOG(INFO) << help(visible) << std::endl;
    }
    
    notify(args);
    
    return args;
}
