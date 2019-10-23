import csv
import numpy as np
import pandas as pd 
from sklearn import metrics
from sklearn import datasets
from itertools import combinations
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Path to the dataset
file_path = 'Data.csv'
#import dataset
signaldata = pd.read_csv(file_path)

features = ['RMSEVM', 'MAXEVM', 'EYEAMP', 'EYESNR', 'EYEDELAY', 'EYEWIDTH', 'ENERGY', 'BPR', 'MEANEIGEN']

# FAKE INPUT DATA
signaldata = pd.DataFrame(np.random.randint(1, 10, size=(10, len(features))), columns=features)
signaldata['LABEL'] = np.random.randint(0, 2, size=(10, 1))

# Create all combinations list in one line
combofallfeat = sum([list(combinations(features, i)) for i in range(1,10)], [])

y = signaldata.LABEL
results = []

#set x to be our features used in training
for comb_features in list(combofallfeat):
    # Filter data by comb_features
    X = signaldata[list(comb_features)]

    # Train and evaluate your classifier
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)
    clf = RandomForestClassifier(n_estimators=100)
    clf.fit(X_train,y_train)
    y_pred=clf.predict(X_test)
    accuracy = metrics.accuracy_score(y_test, y_pred)
    row_res = {"features": comb_features, "accuracy": accuracy, "feature_importances_": clf.feature_importances_}

    #print(row_res)

    # Store result
    results.append(row_res)

# Sort result by accuracy
sorted_results = sorted(results, key = lambda i: i['accuracy'], reverse=True)

# Print top 3 results
print(sorted_results[:])

#writing results to an excel file
csvData = [sorted_results[:]]

with open('results.csv', 'w') as csvFile:
    writer = csv.writer(csvFile)
    writer.writerows(csvData)
    
csvFile.close()
