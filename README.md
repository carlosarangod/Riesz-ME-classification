# Riesz-Micro-Expression-classification
This is the companion code of "Mean Oriented Riesz Features for Micro Expression Classification". This project reads image sequences from different micro-expression databases, detect and track the faces in the sequence. The face sequences are processed using the Riesz pyramid to compute phase differences between consecutive frames. This data is extracted as a series of histograms. These features are then used to train a classification model. 

## Getting Started

### Prerequisites

For capturing the micro-expression datasets and extracting their features it's required to have Matlab with the following toolboxes:
- Image Processing Toolbox
- Computer Vision Toolbox

For classifying the micro-expressions it's required to have Python installed with the following libraries:
- NumPy
- SciPy
- scikit-learn

### Databases Supported

* [SMIC](https://www.oulu.fi/cmvs/node/41319) - Spontaneous Micro-expression Database
* [CASME II](http://fu.psych.ac.cn/CASME/casme2-en.php) - Chinese Academy of Sciences Micro-Expressions database
* [CAS(ME)²](http://fu.psych.ac.cn/CASME/casme2-en.php) - Chinese Academy of Sciences Macro-Expressions and Micro-Expressions
* [CK+](http://fu.psych.ac.cn/CASME/casme2-en.php) - The Extended Cohn-Kanade Dataset

### Reading the databases
The user needs to specify the directory of the database in 

## Authors

- __Carlos Arango Duque__ - *Université Clermont Auvergne*
- **Olivier Alata** - *Laboratoire Hubert Curien, Universite Jean Monnet*
- **Hubert Konik** - *Laboratoire Hubert Curien, Universite Jean Monnet*
- **Anne-Claire Legrand** - *Laboratoire Hubert Curien, Universite Jean Monnet*

## Sources
1. [Arango Duque, Carlos & Alata, Olivier & Emonet, Rémi & Konik, Hubert & Legrand, Anne-Claire. "Mean Oriented Riesz Features for Micro Expression Classification",
*Pattern Recognition Letters*] (https://www.sciencedirect.com/science/article/abs/pii/S0167865520301781)
2. [Wadhwa, Neal & Rubinstein, Michael & Durand, Fredo & Freeman, William. "Riesz pyramids for fast phase-based video magnification" *2014 IEEE International Conference on Computational Photography*] (http://people.csail.mit.edu/nwadhwa/riesz-pyramid/)
