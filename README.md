# Riesz-Micro-Expression-classification
This is the companion code of "Mean Oriented Riesz Features for Micro Expression Classification". This project reads image sequences from different micro-expression databases, detect and track the faces in the sequence. The face sequences are processed using the Riesz pyramid to compute phase differences between consecutive frames. This data is extracted as a series of histograms. These features are then used to train a classification model. If you reuse this code for your academic publications, please cite the original paper:
```
@article{DUQUE2020,
title = "Mean Oriented Riesz Features for Micro Expression Classification",
journal = "Pattern Recognition Letters",
year = "2020",
issn = "0167-8655",
doi = "https://doi.org/10.1016/j.patrec.2020.05.008",
url = "http://www.sciencedirect.com/science/article/pii/S0167865520301781",
author = "Carlos Arango Duque and Olivier Alata and Rémi Emonet and Hubert Konik and Anne-Claire Legrand",
}
```

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

### Running it, step by step

- Download any of the databases previously mentioned
- Specify the location of the database's directory in "Image acquisition/Img_from_database.m".
```
1: data_dir = 'C:\Databases\Emotions\SMIC-E_raw image';
```
- 


## Authors

- __Carlos Arango Duque__ - *Université Clermont Auvergne*
- **Olivier Alata** - *Laboratoire Hubert Curien, Universite Jean Monnet*
- **Rémi Emonet** - *Laboratoire Hubert Curien, Universite Jean Monnet*
- **Hubert Konik** - *Laboratoire Hubert Curien, Universite Jean Monnet*
- **Anne-Claire Legrand** - *Laboratoire Hubert Curien, Universite Jean Monnet*

## Other Sources
1. [C. A. Duque, O. Alata, R. Emonet, A. Legrand and H. Konik, "Micro-Expression Spotting Using the Riesz Pyramid" *2018 IEEE Winter Conference on Applications of Computer Vision (WACV)*] (https://ieeexplore.ieee.org/abstract/document/8354118)
2. [Wadhwa, Neal & Rubinstein, Michael & Durand, Fredo & Freeman, William. "Riesz pyramids for fast phase-based video magnification" *2014 IEEE International Conference on Computational Photography*] (http://people.csail.mit.edu/nwadhwa/riesz-pyramid/)
