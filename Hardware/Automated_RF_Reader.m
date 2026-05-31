%Andrew Plesniak
%10/4/2018
%This code serially connects to a function generator and instructs it to produce a signal
%of sweeping frequency which is sent to a RF antenna transmiter.
%At each frequency point, the signal recieved by an RF antenna reciever is
%measured by a peak detector which is sent to an arduino, which in turn
%sends it to Matlab via serial connection. After the frequency sweep is
%finished, Matlab send serial commands that instruct the arduino to cuase the linear actuator
%to move the RF reciever to the next test position. 
clear
clc
disp('Please wait... Intializing Communications');
if ~isempty(instrfind)  %closes any exsisting communcations
    fclose(instrfind);
    delete(instrfind);
end

%arduino communication setup
movecommand = 'M';
getdatacommand = 'C';
acknowledge = 'A';
done = 'D';
arduino = serial('COM4');
arduino.Terminator = {'CR/LF',''};
fopen(arduino);
pause(2);

% VISA driver for function generator
dsg3000 = visa( 'ni','USB0::0x1AB1::0x0992::DSG3B191900011::INSTR' );
fopen( dsg3000 ); %Open the visa object created
pause(2);

%intial values and setup
position = [10,5,0,-5,-10]; % must have zero in center of array and be in ascending order form left to right
numPositions = size(position,2);
currentPositionIndex = floor(numPositions/2) + 1;
currentPosition = position(currentPositionIndex); %should intially be zero
clc
numTrials = 1;
lowFreq = input('What is the lowest desired testing frequency (MHz): ');
highFreq = input('What is the highest desired testing frequency (MHz): ');
deltaFreq = input('What is the desired frequency resolution (delta-Freq) (MHz): ');
foldername = input('Enter a new folder name to save the data and figures under (antenna identifier): ','s');

numFreqs= (highFreq - lowFreq)/deltaFreq + 1;
freq = linspace(lowFreq, highFreq, numFreqs);
voltage = zeros(1,numFreqs);
data_test = zeros(numFreqs, numPositions);
j = 1;

%move to minimum position
relNextPosition = position(1)-position(currentPositionIndex);
arduinoMove(arduino, relNextPosition, movecommand, acknowledge, done); %sends the number of inches to move to the arduino
currentPositionIndex=1;
direction = 1; 

for z = 0 : (numPositions*numTrials - 1)
    clc
    fprintf('Trial Set Number: %d out of %d\n', floor(z/numPositions)+1,numTrials) 
    fprintf('     Currently Gathering Data at Position = %d inches\n', position(currentPositionIndex))
    
    % this is where frequency is swept
    for i = lowFreq:deltaFreq:highFreq
        %Sets Frequency on the Function Generator
        [meas_RF_FREQ, meas_RF_LEV] = setFreq(dsg3000, i);
        
        %data is read from the arduino (average of 5 readings done in arduino code)
        voltage(j) = arduinoGetData(arduino, getdatacommand, acknowledge, done);
        j = j + 1;
    end
    j = 1;
    
    % put data into a matrix of the format that can be indexed as:
    % data(trialnumber, frequencyIndex, positionIndex)
    data_test(floor(z/numPositions)+1,currentPositionIndex) = voltage/0.0293 - 86.4; %conversion from V to dBm found in datasheet
   
    %turns direction around if at end of position array and moves to the
    %next position
    direction = determineDirection(direction, currentPositionIndex, numPositions);
    relNextPosition = position(currentPositionIndex+direction)-position(currentPositionIndex);
    currentPositionIndex = currentPositionIndex+direction;
    arduinoMove(arduino, relNextPosition, movecommand, acknowledge, done); %sends the number of inches to move to the arduino
end
clc

relNextPosition = -position(currentPositionIndex);
arduinoMove(arduino,relNextPosition,movecommand,acknowledge,done);

%Plots the grouped position grouped data into 3d plots
%then averages powergains across the trials to come up with a 2d signiature

%Saves Figures and Data
user = userpath;
dir = char(strcat(user(1:end-1),'\Data\',foldername,'\',datestr(now,'dd-mmm-yyyy HH_MM_SS')));
filenames = fullfile(dir,{'Data.mat';'3dProfiles.fig';'AveragedProfiles.fig';'OverlayedAverages.fig'});
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(dir);
save(char(filenames(1)));
%save(char(filenames(1)), 'data', 'position', 'freq');
addpath(genpath(userpath))
clc
disp('Data Collection Done!')
save('data_test.mat','data_test');
%workspace cl
fclose('all');
delete(arduino);
delete(dsg3000);


%%%%%%%%%%%%%%%%%%%%%%  NN test  %%%%%%%%%%%%%%%
m = size(result_2d,1);
n = size(result_2d,2);
h = size(result_2d,3);

for i = 1:m
    x_train(i,:) = result_2d(i,1:n-h);
    y_train(i,:) = result_2d(i,n-h+1:n);
end

net=patternnet(10);

%% sets the parameters of the NN model
%% see the NN toolbox documentation
net.trainParam.epochs = 1000;
net.trainParam.show = 10;
net.trainParam.max_fail=2;
%%% use conjugate gradient to train the model
net.trainFcn='traingd';

net= train(net,x_train',y_train');
y_predict = net (data_test');
[M,index] = max(y_predict);



