#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep  8 18:49:55 2021

@author: fabioacl
"""

#%% Imports

print('Importing libraries...')
import numpy as np
import os
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
    
print('Importing classes...')
import keras
import tensorflow as tf
import keras.backend as K
import pickle

'''Specitify for training keras models'''
def specificityKeras(y_true, y_pred):
    true_negatives = K.sum(K.round(K.clip((1 - y_true) * (1 - y_pred), 0, 1)))
    possible_negatives = K.sum(K.round(K.clip(1 - y_true, 0, 1)))
    return true_negatives / (possible_negatives + K.epsilon())

modelNumber = 0

modelPath = f'ica_classifier_{modelNumber}.h5'

leakyReluActivation = tf.nn.leaky_relu
    
model = keras.models.load_model(modelPath,custom_objects = {'leaky_relu':leakyReluActivation,
                                                            'specificityKeras':specificityKeras})

normValuesPath = f'standardisationValues_{modelNumber}.pkl'

normValues = np.load(normValuesPath,allow_pickle=True)

timeSeriesFilename = 'ica_timeseries.txt'

icaTimeSeries = np.loadtxt(timeSeriesFilename, delimiter=",")
icaTimeSeries = np.expand_dims(icaTimeSeries,axis=(2,3))
icaTimeSeries = (icaTimeSeries-normValues[0][0])/normValues[0][1]

psdFilename = 'ica_psd.txt'

icaPsd = np.loadtxt(psdFilename, delimiter=",")
icaPsd = np.expand_dims(icaPsd,axis=(2,3))

topoplotFilename = 'ica_topoplot.txt'

icaTopoplot = np.loadtxt(topoplotFilename, delimiter=",")
correctedIcaTopoplot = []
icaTopoplotSize = icaTopoplot.shape[1]
numberComponents = int(icaTopoplotSize/67) #Topoplot is a squared matrix 67 by 67

# From 2D array to 3D array
for componentIndex in range(numberComponents):
    componentTopoplotData = np.nan_to_num(icaTopoplot[:,componentIndex*67:(componentIndex+1)*67])
    correctedIcaTopoplot.append(componentTopoplotData)

icaTopoplot = np.array(correctedIcaTopoplot)

icaTopoplot = np.expand_dims(icaTopoplot,axis=3)

normalisedIcaPsd = []
normalisedIcaTopoplot = []

for componentIndex in range(numberComponents):
    # Normalize PSD and Topoplot converting them to an image sample
    currentIcaPsd = icaPsd[componentIndex]
    maxDataFile = np.amax(currentIcaPsd)
    minDataFile = np.amin(currentIcaPsd)
    currentIcaPsd = (currentIcaPsd-minDataFile)/(maxDataFile-minDataFile)
    
    currentIcaTopoplot = icaTopoplot[componentIndex]
    maxDataFile = np.amax(currentIcaTopoplot)
    minDataFile = np.amin(currentIcaTopoplot)
    currentIcaTopoplot = (currentIcaTopoplot-minDataFile)/(maxDataFile-minDataFile)
    currentIcaTopoplot = currentIcaTopoplot[::-1]
    
    normalisedIcaPsd.append(currentIcaPsd)
    normalisedIcaTopoplot.append(currentIcaTopoplot)
    
icaPsd = np.array(normalisedIcaPsd)
icaTopoplot = np.array(normalisedIcaTopoplot)
    
icaPsd = (icaPsd-normValues[1][0])/normValues[1][1]
icaTopoplot = (icaTopoplot-normValues[2][0])/normValues[2][1]

icaSample = [icaTimeSeries,icaPsd,icaTopoplot]
            
predictedLabel = model.predict(icaSample)
predictedLabel = np.argmax(predictedLabel,axis=1)

np.savetxt('ica_components_labels.txt', predictedLabel)