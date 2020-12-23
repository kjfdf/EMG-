clear;
pathName = '/Volumes/NO NAME/EMG_data/normal_data';
cd(pathName);
%fileName = '52239607 - 2020-06-05 10_52_58 AM - Needle EMG - R TIB ANTERIOR';

% bring all files in directory
fileList = dir ('*.txt.');
numData = length(fileList);
%모든 정상데이터가 한폴더에 있기때문, 모든 파일은 NL로 이름이 바뀔것. pathName 바꿀때 class도 바꿀것.
class = 'NL';

for i = 1:numData
    fid = fopen(strcat(pathName, fileList(i).name),'r');
    fileName = fileList(i).name;
    
    patientNum = extractBetween(fileName, 1, 8);
    muscle = extractBetween(fileName, "Needle EMG - ", '.txt');
    patientName = '';
    
    for k = 1:21
        currLine = fgetl(fid);
        if (startsWith (currLine, 'Family Name='))
            currLine = currLine(13:length(currLine));
            patientName = currLine;
        elseif (startsWith (currLine, 'First Name='))
            currLine = currLine(12:length(currLine));
            patientName = strcat(patientName, currLine);
        end
    end

    patientName = erase(patientName, '.');
    patientNum = string(patientNum);
    muscle = string(muscle);
    
    newName = strcat(patientNum, '_', patientName, '_', muscle, '_', class, '.txt');
    %movefile (fileName, newName, 'f');
     
    disp (newName);
end