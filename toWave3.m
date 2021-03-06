clear;

pathName = 'C:\Users\SNUH\Desktop\유일한\EMG 머신러닝 연구\EMG_data\figure4\';
cd(pathName);
% fileName = '01051127751 - 2020-07-30 3_24_44 PM - Needle EMG - R ADD POLLICIS - Site 1.txt';

% bring all files in directory
fileList = dir ('*.txt.');
numData = length(fileList);

traceDuration = 0; 
sampleNum = 200;
ampRange = 0;

for i=1:numData
%open file
    str=[]
    fd=fopen(strcat(pathName,fileList(i).name),'r')
    l=fgetl(fd)
    while ischar(l)
        str{end+1,1}=l;
        l=fgetl(fd);
    end
    fclose(fd)
    clc
    str
    f=regexpi(str,'[e\-\+\d\.]+')
    idx=cellfun(@numel,f)
    id=idx==2
    ii1=strfind([0 id'],[0 1])  % Begin
    ii2=strfind([id' 0],[1 0])  % End
    fid = fopen(strcat(pathName,fileList(i).name),'r');
    fileName=fileList(i).name;
    %fids = fopen('all');
    startIndex=length('Sweep  Data(mV)<960>=');
    disp(startIndex);
    tSignal= '';
    for i=min(ii1):max(ii2)
        try
         currLine = fgetl(fid);
         %sweepData = startsWith (currLine, 'Sweep  Data(mV)<960>=');
         if (startsWith (currLine, 'Sweep  Data(mV)<960>='))
             currLine = currLine(startIndex+1:length(currLine));
             tSignal = [tSignal, currLine];
         elseif (startsWith (currLine, 'Trace Duration(ms)='))
             currLine = currLine (20:length(currLine));
             traceDuration = str2double(currLine)/1000;
         elseif (startsWith (currLine, 'Amplifier Range'))
             currLine = currLine (21:length(currLine));
             ampRange = str2double(currLine);
         end
        end
    end
  

    %while ~feof(fid)
    %convert str to float
    nSignal = strread (tSignal, '%f');

    %% plot
    %time = 0:length(nSignal):traceDuration*sampleNum;
    time = 0:traceDuration/1000:traceDuration*length(nSignal)/1000 - traceDuration/1000;

%     EMGfigure=figure('fileName','figure','NumberTitle','off');
    f=figure('visible','off');
    plot (time, nSignal);
    %ylim ([-0.05 0.05]);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    xlabel('time(s)');  
    fileN=extractBefore(fileName,".txt")
    print(fileN,'-dpng')
%     exportgraphics(f,
    close(f)
end