# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Makefile for preClassifier
#
# @author skletz
# @version 1.0, 27/03/18
# -----------------------------------------------------------------------------
# CMD Arguments:	--
# -----------------------------------------------------------------------------
# @TODO:
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Compiler, flags
CXX=g++
CXXFLAGS=-std=c++11 -m64

#Caffe settings
CAFFE_CPU_ONLY=1

ifeq ($(CAFFE_CPU_ONLY),0)
	CAFFE_LD_FLAGS = -L/usr/local/cuda/lib
	CAFFE_LD_FLAGS += -L/usr/local/cuda/lib64
	CAFFE_LD_FLAGS += -lcudart
	CAFFE_LD_FLAGS += -lcublas
	CAFFE_LD_FLAGS += -lcurand
	CAFFE_LD_FLAGS += -lcudnn
else
        CXXFLAGS += -DCPU_ONLY=1
endif

# Output directory
BUILD =	builds
BIN =	darwin/bin
# LIB =	linux/lib
EXT =	darwin/ext

# Project settings
PROJECT=preClassifier
VERSION=1.0

SRC= $(PROJECT)/src
SOURCES=$(wildcard $(SRC)/*.cpp)
OBJECTS=$(patsubst $(SRC)/%.cpp,$(BUILD)/$(EXT)/%.o,$(SOURCES))

# Default settings for opencv installation directory
# OPENCVDIR := /usr/local/
# Prints -I/usr/local/include/opencv -I/usr/local/include
# INCDIR = `pkg-config --cflags opencv`

INCDIR = -I/usr/local/include
INCDIR += -I/usr/local/include/opencv
INCDIR += -I/usr/local/opt/openblas/include
INCDIR += -I${CAFFE_ROOT}/build/install/include
INCDIR += -I/usr/local/Cellar/glog/0.3.5_3/include

# operating system can be changed via command line argument
ifeq ($(os),win)
	BIN := win/bin
	LIB := win/lib
	EXT := win/ext
endif

LDLIBSOPTIONS += -L/usr/local/lib
LDLIBSOPTIONS += -L/usr/local/opt/openblas/lib
LDLIBSOPTIONS += -L/usr/local/Cellar/glog/0.3.5_3/lib
LDLIBSOPTIONS += -L${CAFFE_ROOT}/build/install/lib
LDLIBSOPTIONS += -L/usr/local/share/OpenCV/3rdparty/lib
LDLIBSOPTIONS_POST =`pkg-config --libs opencv`

LDLIBSOPTIONS += -lboost_system -lboost_filesystem -lboost_serialization -lboost_program_options -lboost_thread
#IMPORTANT: Link sequence! - OpenCV libraries have to be added at the end
LDLIBSOPTIONS += $(LDLIBSOPTIONS_POST)
LDLIBSOPTIONS += -lglog -lcaffe

.PHONY: all

all: clean directories prog

directories:
	@echo "==============================================================================" ;
	@echo "Making Directories"
	@echo "==============================================================================" ;
	mkdir -p $(BUILD)/$(BIN)
	mkdir -p $(BUILD)/$(LIB)
	mkdir -p $(BUILD)/$(EXT)

prog: obj
	@echo "==============================================================================" ;
	@echo "Making Program"
	@echo "==============================================================================" ;

obj: $(OBJECTS)
			$(CXX) $(CXXFLAGS) $(OBJECTS) -o $(BUILD)/$(BIN)/prog$(PROJECT).$(VERSION) $(LDLIBSOPTIONS)

$(BUILD)/$(EXT)/%.o: $(SRC)/%.cpp
		$(CXX) $(CXXFLAGS) -fPIC -c $< -o $@ $(INCDIR)

clean:
	rm -rf $(BUILD)

info:
	#@echo "OpenCV Installation: " $(OPENCVDIR) "\n"
	@echo "Header Include Directory: " $(INCDIR) "\n"
	@echo "Linking Libraries: " $(LDLIBSOPTIONS) "\n"
