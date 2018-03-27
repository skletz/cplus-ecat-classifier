#include "util.hpp"

bool Util::isFileHidden(const boost::filesystem::path &p)
{
    boost::filesystem::path name = p.filename();
    if(name != ".." &&
       name != "."  &&
       name.string()[0] == '.')
    {
        return true;
    }
    
    return false;
}

std::vector<int> Util::Argmax(const std::vector<float>& v, int N)
{
    std::vector<std::pair<float, int> > pairs;
    for (size_t i = 0; i < v.size(); ++i){
        pairs.push_back(std::make_pair(v[i], i));
    }
    
    std::partial_sort(pairs.begin(), pairs.begin() + N, pairs.end(), &Util::PairCompare);
    
    std::vector<int> result;
    for (int i = 0; i < N; ++i){
        result.push_back(pairs[i].second);
    }
    
    return result;
}

bool Util::PairCompare(const std::pair<float, int>& lhs, const std::pair<float, int>& rhs)
{
    return lhs.first > rhs.first;
}

void Util::showProgress(std::string _label, int _step, int _total)
{
    printf("\r");
    int tmptotal = _total;
    if (tmptotal == 0)
    {
        tmptotal = 1;
    }
    
    //progress width
    const int pwidth = 72;
    
    //minus label len
    int width = pwidth - int(_label.length());
    int pos = (_step * width) / tmptotal;
    
    
    int percent = (_step * 100) / tmptotal;
    
    
    printf("%s[", _label.c_str());
    
    //fill progress bar with =
    for (int i = 0; i < pos; i++)  printf("%c", '=');
    
    //fill progress bar with spaces
    printf("%*c", width - pos + 1, ']');
    printf(" %3d%%\r", percent);
}
