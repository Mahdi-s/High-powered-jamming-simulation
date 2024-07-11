# 📡 ADS-B Jamming Simulation and ML Detection 🛩️

## 🎯 Project Overview

This project combines a MATLAB simulation of high-powered jamming attacks on ADS-B devices with a Python-based machine learning model for detecting such attacks.

### 🔬 MATLAB Simulation

The MATLAB component simulates a communication system under jamming conditions, focusing on:

- AWGN channel modeling
- SNR, EVM, and Eye Diagram feature extraction
- CRC-based error detection

### 🤖 Machine Learning Model

The Python script implements a Random Forest Classifier to detect jamming attacks based on the features extracted from the MATLAB simulation.

## 🚀 Getting Started

### Prerequisites

- MATLAB (version R2019b or later recommended)
- Python 3.7+
- Required Python libraries: numpy, pandas, scikit-learn

## 🛠️ Usage

1. Run the MATLAB simulation:
```
CommunicationSimulator
```
This will generate the `EVMdata.xlsx` file.

2. Rename `EVMdata.xlsx` to `Data.csv`.

3. Run the Python ML model:
```
python MLmodel.py
```
## 📊 Features

The ML model uses the following features extracted from the MATLAB simulation:
```
features = ['RMSEVM', 'MAXEVM', 'EYEAMP', 'EYESNR', 'EYEDELAY', 'EYEWIDTH', 'ENERGY', 'BPR', 'MEANEIGEN']
```
## 🔍 Results

The ML model evaluates different combinations of features and outputs the top results based on accuracy. Results are saved in `results.csv`.

## 📚 Further Reading

For more information on the underlying concepts, please visit: [IEEE Paper](https://ieeexplore.ieee.org/document/8833789)

## 🙏 Acknowledgements

- IEEE for the original paper
- Contributors and maintainers of the scikit-learn library

