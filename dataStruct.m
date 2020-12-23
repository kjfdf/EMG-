clear all;

pathName = 'C:\Users\SNUH\Desktop\유일한\EMG 머신러닝 연구\EMG_data\myopathy_data\';
cd(pathName);

% bring all files in directory
dataList = dir ('*.txt.');
numData = length(dataList);

traceDuration = 0; 
sampleNum = 200;
data = cell(6,30)

for i = 1:numData
    fid = fopen(strcat(pathName, dataList(i).name),'r');
    fileName = dataList(i).name;
    fileName = fileName(1:end-4);
    label = fileName(end);
    patientNum = extractBefore(fileName,9);
    
    startIndex=length('Sweep  Data(mV)<960>=');
    tSignal= '';
    muscleName='';
    
    while ~feof(fid)
        currLine = fgetl(fid);
        
        if (startsWith (currLine, 'Sweep  Data(mV)<960>='))
            currLine = currLine(startIndex+1:length(currLine));
            tSignal = [tSignal, currLine]; %근전도 신호 숫자값 tSignal에 입력
        elseif (startsWith (currLine, 'Trace Duration(ms)='))
            currLine = currLine (20:length(currLine)); 
            traceDuration = str2double(currLine)/1000; %문자형 벡터를 숫자로 전환함
        elseif (startsWith (currLine, 'Master Anatomy='))
            currLine = currLine (16:length(currLine));
            muscleName = currLine;
        end
        
    end
    
    %convert str to float
    nSignal = strread (tSignal, '%f');
    
    disp(fileName);
    xstart = input("starting point");
    xend = input("end point");
    
    xs=(xstart*1000)+1
    xe=xend*1000
    
    nSignal_trim = nSignal(xs:xe);
    
    signal(:,i) = nSignal_trim
    z=i-1
    if z>0 & patientNum==data{6,z}
        age=data{3,i-1}
        sex=data{4,i-1}
        CK=data{5,i-1}
%     else
%         age=input("age");
%         sex=input("sex",'s');
%         CK=input("CK");
    end
    
    data{1,i} = label;
    data{2,i} = muscleName;
%     data{3,i} = age;
%     data{4,i} = sex;
%     data{5,i} = CK;
    data{6,i} = patientNum;
    
end

save ('finalData.mat', 'data', 'signal');

