# -*- coding: utf-8 -*-
"""
Created on Tue Aug 20 17:22:44 2019

@author: carlo
"""


import numpy as np
import scipy.io as sio
#from sklearn import svm, datasets
#from sklearn.neighbors import KNeighborsClassifier
#from sklearn.neural_network import MLPClassifier
#from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
from sklearn.metrics import f1_score

import time

#Database = 'SMIC_High'
Database = 'CASME2'

mat_contents = sio.loadmat(Database + '_labels.mat')
Subject_label = mat_contents['Subject_label']
Subset_label = mat_contents['Subset_label']
Emotion_label = mat_contents['Emotion_label']

Extract_Feat = sio.loadmat('Riesz_Histograms_Dmean_' + Database + '.mat')
Riesz_Hist_grid_para = Extract_Feat['Riesz_Hist_grid_para']


Subject_num = len(Subject_label)
Riesz_class_acc = np.zeros((7,7,7,3))
Riesz_class_f1 = np.zeros((7,7,7,3))
Riesz_class_f2 = np.zeros((7,7,7,3))

#####  SVM parameters
models = SVC(kernel='poly')
#C_range = np.logspace(-2, 10, 13)
#gamma_range = np.logspace(-9, 3, 13)
#gamma_range = np.logspace(-5, 3, 9)
C_range = np.logspace(-2, 4, 7)
gamma_range = np.logspace(-1, 5, 7)
param_grid = dict(gamma=gamma_range, C=C_range)

if Database == 'SMIC_High':
    Second_Emo = mat_contents['Second_Emo']
    Subject_label = np.vstack([Subject_label,Subject_label[Second_Emo[:,0]]])
    Emotion_label = np.vstack([Emotion_label,Emotion_label[Second_Emo[:,0]]])

O = 0   
Gx = 0
Gy = 0
R = 0
M = 0

Save_file = 'Riesz_classification_CASME2.mat'

# mat_contents = sio.loadmat(Save_file)
# Riesz_class_acc = mat_contents['Riesz_class_acc']

while O < 7 :
    while Gx < 7:
        while Gy < 7:
            while R < 3:

                start = time.time()
                Riesz_features_temp = Riesz_Hist_grid_para[0,O,Gx,Gy,R]
            
                Riesz_features = np.array([]).reshape(0,Riesz_features_temp.size)
            
                for i in range(Subject_num):
                    Riesz_features_temp = Riesz_Hist_grid_para[i,O,Gx,Gy,R]
                    Riesz_features = np.vstack([Riesz_features, Riesz_features_temp])
                    
                if Database == 'SMIC_High':
                    Extract_Feat = sio.loadmat('Riesz_Histograms_Dmean_secemo_' + Database + '.mat')
                    Riesz_Hist_grid_parab = Extract_Feat['Riesz_Hist_grid_parab']
                    
                    for i in range(Second_Emo.shape[0]):
                        Riesz_features_temp = Riesz_Hist_grid_parab[i,O,Gx,Gy,R]
                        Riesz_features = np.vstack([Riesz_features, Riesz_features_temp])
                    
                Subject_list = np.unique(Subject_label)
                Accuracy_mat = np.zeros((1,len(Subject_list)))
                
                Predicted_emo_tot = np.array([],dtype='uint8').reshape(0,)
                Test_emo_tot = np.array([],dtype='uint8').reshape(0,1)
                
                                
                for k in range(len(Subject_list)):
                    subject = Subject_list[k]
                    Test_index = np.where(Subject_label == subject)
                    Train_index = np.where(Subject_label != subject)
                    
                    Test_feat = Riesz_features[Test_index[0],:]
                    Train_feat = Riesz_features[Train_index[0],:]
                    Test_emo = Emotion_label[Test_index[0],:]
                    Train_emo = Emotion_label[Train_index[0],:]
                    
                    
                    grid = GridSearchCV(models, param_grid=param_grid, cv=5)
                    grid.fit(Train_feat, Train_emo.ravel())
                    Predicted_emo = grid.predict(Test_feat)
                    Predicted_emo_tot = np.hstack([Predicted_emo_tot,Predicted_emo])
                    Test_emo_tot = np.vstack([Test_emo_tot,Test_emo])
                    
                accuracy_tot = accuracy_score(Test_emo_tot,Predicted_emo_tot)
                F1_tot = f1_score(Test_emo_tot,Predicted_emo_tot,average = 'micro')
                F1_tot2 = f1_score(Test_emo_tot,Predicted_emo_tot,average = 'macro')

                Riesz_class_acc[O,Gx,Gy,R] = accuracy_tot
                Riesz_class_f1[O,Gx,Gy,R] = F1_tot
                Riesz_class_f2[O,Gx,Gy,R] = F1_tot2
                end = time.time()
                elapsed = end - start
                print("M=%d O=%d, Gx=%d, Gy=%d, R=%d, accuracy=%0.4f, f1-score=%0.4f, f2-score=%0.4f. The time elapsed is  %0.2f seconds"
                      % (M,O,Gx,Gy,R,accuracy_tot,F1_tot,F1_tot2,elapsed))
                # sio.savemat(Save_file, {'Riesz_class_acc': Riesz_class_acc, 'Riesz_class_f1' : Riesz_class_f1, 'Riesz_class_f2' : Riesz_class_f2})
                R += 1
            R = 0
            Gy += 1
        Gy = 0
        Gx += 1
    Gx = 0
    O += 1
