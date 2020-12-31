clear;

set(0,'DefaultFigureWindowStyle','docked')
% set(0,'DefaultFigureWindowStyle','normal')

pathName = 'C:\Users\SNUH\Desktop\유일한\EMG 머신러닝 연구\EMG_data\figure4\';
cd(pathName);
% fileName = '01051127751 - 2020-07-30 3_24_44 PM - Needle EMG - R ADD POLLICIS - Site 1.txt';

% bring all files in directory
fileList = dir ('*.txt.');
numData = length(fileList);

traceDuration = 0; 
sampleNum = 200;
ampRange = 0;
data = cell(6,500)
nSignals=[0];
signals='';

for i=1:numData
%open file
    str=[]
    fd=fopen(strcat(pathName,fileList(i).name),'r')
    fileName = fileList(i).name;
    fileName = fileName(1:end-4);
    label = fileName(end);
    patientNum = extractBefore(fileName,9);
    patientName = extractBetween(fileName,10,12);
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
    %fids = fopen('all');
    startIndex=length('Sweep  Data(mV)<960>=');
    disp(startIndex);
    tSignal= '';
    muscleName='';
    for j=min(ii1):max(ii2)
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
         elseif (startsWith (currLine, 'Master Anatomy='))
            currLine = currLine (16:length(currLine));
            muscleName = currLine;
         end
        end
    end
  

    %while ~feof(fid)
    %convert str to float
    nSignal = strread (tSignal, '%f');

    %% plot
    %time = 0:length(nSignal):traceDuration*sampleNum;
    time = 0:traceDuration/1000:traceDuration*length(nSignal)/1000 - traceDuration/1000;

    EMGfigure=figure('fileName','figure','NumberTitle','off');
%     f=figure('visible','off');
    tiledlayout(2,1)
    subplot(3,3,[1:3])
    plot (time, nSignal,'k.');
    topAxs=gca;
    axis tight
    
%     amplitude를 0.2mV로 자른 그래프를 메인으로 해서 위치시킴.
    subplot(3,3,[4:9])
    main=plot(time, nSignal)
    ylim([-5 5])
    set(gca,'YTick',[-5:0.2:5]) %y축의 눈금을 0부터 5까지 0.2간격으로 조정
    set(gca,'XTick',[0:0.01:30]) %x축의 눈금을 0부터 30까지 0.01간격으로 조정 
    
    mainAxs = gca;
    mainAxsRatio = get(mainAxs,'PlotBoxAspectRatio')
%     main그래프를 크게 하고 원래 그래프를 작게해서 위치시킴. 
    mainAxsratio = mainAxs.PlotBoxAspectRatio(1)/mainAxs.PlotBoxAspectRatio(2);
    topAxsratio = mainAxsratio * mainAxs.Position(3)/topAxs.Position(3);
    topAxs.PlotBoxAspectRatio = [topAxsratio, 1, 3];
    
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    xlabel('time(s)');
    ylabel('amp(mV)');
    title(fileName);
%     plot이름은 txt파일 이름 그대로 가져옴
    savefig(fileName)
%     pause시간=20초 동안 plot자를 부분 편집해서 brushedData로 넘겨줌, brushedData 저장시 뒤에 숫자
%     지우고 덮어쓰기로 brushedData로 저장할 것. figure창에서 처음 조작시 zoom-in mode로 시작. 
    pause on   
    linkdata on 
    zoom on
%     waitforbuttonpress 마우스클릭이나 키보드 누르면 재시작
    pause %명령 프롬프트창에 키보드 누르면 재시작
%     pause(20) 20초후 재시작 
    close
%     brushedData가 다행으로 되어있으면 그대로, 다열로 되어있으면 모양 반대로 변형해서 nSignal에 하나씩 넣어줌
    if height(brushedData) < width(brushedData)
        nSignal=brushedData';
    else 
        nSignal=brushedData;
    end
%     nSignal_trim으로 nSignal의 값들을 모두 가져옴
    nSignal_trim=nSignal(1:end);
%     nSignals에 nSignal들을 모두 넣어주는데 차원이 모두 달라서 차원이 짧은 경우에는 긴 차원에 맞춰서 없는 값들은
%     0으로 처리해서 대입
    if (size(nSignals(:,1)) == 1)
         nSignals = nSignal;
     else  
         if (length(nSignal) <  length(nSignals(:,1)))
             nSignals = [nSignals [nSignal; zeros(length(nSignals(:,1)) - length(nSignal),1)]];
         end
         if (length(nSignal) == length(nSignals(:,1)))
             nSignals = [nSignals nSignal];
         end
         if (length(nSignal) >  length(nSignals(:,1)))
             nSignals = [[nSignals; zeros(length(nSignal) - length(nSignals(:,1)), length(nSignals(1,:)))] nSignal];
         end
    end            
    data{1,i}=label;
    data{2,i}=muscleName;
    data{3,i}=patientNum;
    data{4,i}=patientName;
    %     fig = openfig(fileN+'.fig');
    %     set(gcf, 'Visible', 'on');
    %     exportgraphics(f,
%     10번 실행할 때 마다 중단여부 묻는 prompt창 나타남, 계속 진행시 그다음부터 진행, 중단시 끝남.
%     if rem(i,10)==0
%         promptMessage = sprintf('계속 진행,\nor 작업중단?');
%         button = questdlg(promptMessage, 'Continue', '계속 진행', '작업중단', '작업중단');
%             if strcmpi(button, '작업중단')
%                 return; % Or break or continue
%             end
%     end
end
% 근전도 데이터값만 있는 signal과 환자 정보가 있는 data로 최종 데이터를 분리하고 저장 
save ('finalData.mat', 'data', 'signal');