
load ('/Users/inayoun/Desktop/data.mat');
load ('/Users/inayoun/Desktop/signal.mat');

%reformat data as categorical

tdata = cell2table (data,...
    'VariableNames',{'Label' 'Muscle' 'Age' 'Gender' 'CK' 'PatientNumber'})
tdata.Label = categorical(tdata.Label);
tdata.Muscle = categorical(tdata.Muscle);
tdata.Age = categorical(tdata.Age);
tdata.Gender = categorical(tdata.Gender);
tdata.PatientNumber = categorical(tdata.PatientNumber);

myoX = [];
myoY = [];
neuroX = [];
neuroY = [];
normalX = [];
normalY = [];

%split data by class
for i = 1:size(data)
        if strcmp(data(i,1),'M')
            myoX = [myoX data(i)]
            myoY = [myoY signal(i,:)]
        elseif strcmp(data(i,1),'N')
            neuroX = [neuroX data(i)]
            neuroY = [neuroY signal(i,:)]
        else
            normalX = [normalX data(i)]
            normalY = [normalY signal(i,:)]
        end
end

%split to train and test
[trainIndM,~,testIndM] = dividerand(58,0.8,0.0,0.2);
[trainIndN,~,testIndN] = dividerand(75,0.8,0.0,0.2);
[trainIndL,~,testIndL] = dividerand(45,0.8,0.0,0.2);

XTrainM = myoX(trainIndM);
YTrainM = myoY(trainIndM);

XTrainN = neuroX(trainIndN);
YTrainN = neuroY(trainIndN);

XTrainL = normalX(trainIndL);
YTrainL = normalY(trainIndL);

XTestM = myoX(testIndM);
YTestM = myoX(testIndM);

XTestN = neuroX(testIndN);
YTestN = neuroY(testIndN);

XTestL = normalX(testIndL);
YTestL = normalY(testIndL);

%repeat to match data num
XTrain = [repmat(XTrainM(1:40), 3); repmat(XTrainN(1:60),2); repmat(XTrainL(1:30), 4)];
YTrain = [repmat(YTrainM(1:40), 3); repmat(YTrainN(1:60),2); repmat(YTrainL(1:30), 4)];

YTestL = num2cell(YTestL);
YTestN = num2cell(YTestN);
XTest = [repmat(XTestM(1:12),15); repmat(XTestN(1:15),12); repmat(XTestL(1:9),20)];
YTest = [repmat(YTestM(1:12),15); repmat(YTestN(1:15),12); repmat(YTestL(1:9),20)];


%Define LSTM network
layers = [ ...
    sequenceInputLayer(178) %should match XTrain row dimension
    bilstmLayer(100,'OutputMode','last')
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer
    ]

options = trainingOptions('adam', ...
    'MaxEpochs',10, ...
    'MiniBatchSize', 150, ...
    'InitialLearnRate', 0.01, ...
    'SequenceLength', 1000, ...
    'GradientThreshold', 1, ...
    'ExecutionEnvironment',"auto",...
    'plots','training-progress', ...
    'Verbose',false);

%Train network. Syntax: net = trainNetwork(sequences,Y,layers,options)
net = trainNetwork(XTrain,YTrain,layers,options);


%Test accuracy
trainPred = classify(net,XTrain,'SequenceLength',100000);
LSTMAccuracy = sum(trainPred == YTrain)/numel(YTrain)*100;

