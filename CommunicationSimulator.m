%======================================================================
% This program simulates a communication being passed through a AWGN
% Channel while measuring the SNR, EVM, and EYE diagram features and
% generating a eyediagram the data is then inserted into a excel file
%======================================================================
close all 
clear all
clc
%%
%======================Initialize system parameters===================
Fc = 2.5e6;                                                                 
Fs = 100;     % Sample rate
Rs = 10;       % Symbol rate
sps = Fs/Rs;    % Samples per symbol
rolloff = 0.5;  % Rolloff factor
M = 2;          % Modulation order (QPSK)
frameLen = 1000;
t = (0:1/Fs:(frameLen/Rs)-1/Fs)';                                          
carrier = sqrt(2)*exp(1i*2*pi*Fc*t);                                        
sizeofBN = sps * frameLen;
start = -25; %Start of SNR
End = 25;  %End of SNR  
SNR = -30:0.1:30;
%SNR = (End-start).*rand(1,100) + start; %used for creating random SNR values 
%%
%=======================Initilizing matrixs=============================
snr = double(zeros(1, length(SNR)));
RMSevm = double(zeros(1, length(SNR)));
MAXevm = double(zeros(1, length(SNR)));
eyeAmp = double(zeros(1, length(SNR)));
eyeSNR = double(zeros(1, length(SNR)));
eyeDelay = double(zeros(1, length(SNR)));
eyeWidth = double(zeros(1, length(SNR)));
BN1 = double(zeros(length(SNR), sizeofBN));
BN2 = double(zeros(length(SNR), sizeofBN));
BN3 = double(zeros(length(SNR), sizeofBN));
BN4 = double(zeros(length(SNR), sizeofBN));
%%
%=====================Adjacent Channel Interference====================
interference = 2*cos(2*pi*Fc*t+pi/8);%.^3;
%%
%========================Square root raised cosine filter==================
filterSpan = 6;
filterGainTx = 9.9121;

transmitFilter = comm.RaisedCosineTransmitFilter('RolloffFactor', rolloff, ...
    'OutputSamplesPerSymbol', sps, ...
    'FilterSpanInSymbols', filterSpan, ...
    'Gain', filterGainTx);

receiveFilter = comm.RaisedCosineReceiveFilter('RolloffFactor', rolloff, ...
    'InputSamplesPerSymbol', sps, ...
    'FilterSpanInSymbols', filterSpan, ...
    'DecimationFactor', 1, ...
    'Gain', 1/filterGainTx);

eyeObj = comm.EyeDiagram(...
    'SampleRate', Fs, ...
    'SamplesPerSymbol', sps, ...
    'DisplayMode', '2D color histogram', ...
    'EnableMeasurements', true,...
    'YLimits', [-2.0 2.0]); 

%%
%===================Generate modulated and pulse shaped signal================
message = randi([0 M-1], frameLen, 1);
[frmError, BPR] = crc(SNR, frameLen, message, interference ,  M, carrier, transmitFilter);
modulated = pskmod(message, M, pi/4);
filteredTx = transmitFilter(modulated);
filteredTxUp = real(filteredTx.*carrier);                                   
idx = round(t*Fs+1);
%Create an eye diagram object
eyeObj(0.5*filteredTx);
reset(eyeObj);
%%
for counter = 1:length(SNR)
%=======================Noise Channel=====================================
channel = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)',...
    'SNR',SNR(counter),'SignalPower',10);

received = channel(filteredTxUp);
receivedACI  = received;% + interference; %Uncomment to add interference to the signal
received1 = receivedACI.*conj(carrier);                                  
filteredRx = receiveFilter(received1);
Energy(counter) = sum(real(filteredRx).^2);
%Update the eye diagram object with the transmitted signal
%reset(eyeObj);
%%
fil = filteredRx'; 
%============================EigenValue==================================
BN1(counter, 2:end)=fil(1:end-1);
BN2(counter, 3:end)=fil(1:end-2);
BN3(counter, 4:end)=fil(1:end-3);
BN4(counter, 5:end)=fil(1:end-4);
AN = [fil; BN1(counter,:); BN2(counter,:); BN3(counter,:); BN4(counter,:)];
CN = cov(AN');
EN(counter,:) = eig(CN);
eyeObj(filteredRx);
%%
%===========================Measuring EVM===============================
evm = comm.EVM('MaximumEVMOutputPort',true, ...
    'ReferenceSignalSource','Estimated from reference constellation', ...
    'ReferenceConstellation',modulated);
rxd = (transmitFilter.FilterSpanInSymbols + receiveFilter.FilterSpanInSymbols)/2;
%EVM measurment 
[rmsEVM,maxEVM] = evm(filteredRx(rxd+1:end))
%%
%========================Write to an array=============================
%================Getting Eye Diagram measurments=======================
meas = measurements(eyeObj);
RMSevm(counter) = round(rmsEVM,2);
MAXevm(counter) = round(maxEVM,2);
eyeAmp(counter) = round(meas.EyeAmplitude,3);
eyeSNR(counter) = round(meas.EyeSNR,3);
eyeDelay(counter) = round(meas.EyeDelay,3);
eyeWidth(counter) = round(meas.EyeWidth,3);
end
mean_eigen =(1/size(AN,1))*sum(EN');
%%
%In order to write the data to an excel file, use the code below
filename = 'EVMdata.xlsx';
T = table(SNR', RMSevm', MAXevm', eyeAmp', eyeSNR', eyeDelay', eyeWidth', Energy' ,BPR', mean_eigen');
T(:,:)
writetable(T, filename) 
winopen(filename)

