import os.path
import glob
import pandas as pd

list=glob.glob("D:/EMG머신러닝연구/윤이나 학생 자료/EMG_data/figure5/*.txt")
data=pd.read_csv("D:/EMG머신러닝연구/윤이나 학생 자료/EMG_data/brushedData2/MoreSelection.csv")
# del list[-2:]
# print(list)
id_total=[]
label_total=[]
for file in list:
    ID_=os.path.basename(file)
    id=ID_.split(".txt")[0]
    id_total.append(id)
    # print(id)
    label=id.split("_")[3]
    label_total.append(label)
    # print(label)
id_total=pd.DataFrame(id_total)
label_total=pd.DataFrame(label_total)
# id1=id.transpose()
# print(id_total,label_total)
data.insert(0,"ID",id_total)
data.insert(1,"label",label_total)
data.to_csv("D:/EMG머신러닝연구/윤이나 학생 자료/EMG_data/brushedData2/MoreSelection2.csv")
