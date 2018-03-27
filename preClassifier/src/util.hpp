//
//  util.hpp
//  preClassifier
//
//  Created by Sabrina Kletz on 22.03.18.
//  Copyright © 2018 Sabrina Kletz. All rights reserved.
//

#ifndef util_hpp
#define util_hpp

#include <string>
#include <algorithm> //std::partial_sort
#include <vector>
#include <functional> //std::bind

#include <boost/filesystem.hpp>

class Util
{
    
public:
    
    static bool isFileHidden(const boost::filesystem::path &p);

    static std::vector<int> Argmax(const std::vector<float>& v, int N);
    
    static bool PairCompare(const std::pair<float, int>& lhs, const std::pair<float, int>& rhs);
    
    /**
     * \brief Writes a progressbar to the terminal and show how manx steps of maximum steps has already been reached.
     * \param _label displayed name in front of the progress bar
     * \param _step current iteration
     * \param _total maximum number of iterations
     */
    static void showProgress(std::string _label, int _step, int _total);
};

#endif /* util_hpp */
