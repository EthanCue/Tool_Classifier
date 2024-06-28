# Automated Tool Identification System using Matlab and K-means
The Automated Tool Identification System is designed to improve processes in construction and manufacturing by facilitating the accurate identification of various tools. This project applies cutting-edge image processing algorithms and machine learning techniques to address real-world industrial challenges. The main components of the system include:

Feature Extraction with Hu Moments: Utilizes Hu Moments to extract unique features from images of tools, allowing for precise identification.
K-means Clustering: Employs K-means clustering to classify tools into predefined categories based on their extracted features.
Visualization and Analysis: Provides detailed visualizations of the classified tools and their features, enhancing understanding and interpretability.
Objectives

General: Streamline the identification of objects to accelerate processes in the construction and manufacturing industries.
Specific:
Reduce accidents related to the incorrect identification of tools and components.
Speed up the processes of sorting and classifying objects in factories and construction sites.
Assist individuals with difficulties distinguishing similar objects, such as those with visual agnosia.
Features

Processes and binarizes images to remove noise and enhance object detection.
Calculates Hu Moments for each detected object to extract distinctive features.
Classifies tools using K-means clustering, with results visualized in 3D plots.
Saves classification results and feature vectors to text files for further analysis.
Supports continuous improvement with the ability to add new training images and retrain the model.
Installation

Download the project files from the provided link.
Ensure MATLAB is installed on your computer.
Extract the downloaded files into a directory of your choice.
Open MATLAB and navigate to the directory containing the project files.
Run the main script (script_principal.m) to start the program.
Usage

Place training images in the Imagenes directory.
Run the main script to process and extract features from the training images.
Place new images to be classified in the test_images directory.
Input the name of the image file (without extension) when prompted.
View classification results in the MATLAB console and saved text files.
Contribution

Contributions to the project are welcome. Feel free to fork the repository and submit pull requests with improvements or new features.
