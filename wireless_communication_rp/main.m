
% Clear all variables
% Close all figures

clear all;
close all;

% % Generate a binary sequence Pr(0) = 0.5 and Pr(1) = 0.5
% binarySequence = rand(1,10)>0.5;

% Load binary sequence from binary_sequence.mat
sequenceStructure = load('binary_sequence');

% Extract binary sequence fields
binarySequence = cell2mat(extractfield(sequenceStructure, 'ip'));

% Convert binary sequence to bipolar sequence
bipolarSequence = 2*binarySequence-1;

% Discrete time sequence bettwen 0 and 10*T with 1000 sampltes
timeSequence = linspace(0, 5, 10000);

% Bit duration in us
bitDuration = 1; 

% Sample frequency assigned by the assistant in MHz
sampleFrequency = 5/bitDuration;

% Error bit used to normalized the amplitude of the signal
erroBit = bitDuration/2;

% Values to BER in dB
berdB = [1:90];

% Carrier frequency
carrierFrequency = 50;

% Upsample factors
upsampleFactors = [1:4];

% Upsample the unipolar sequence and get the vector length
upsampleSequence = upsample(bipolarSequence, upsampleFactors(3));
upsSeqLength = length(upsampleSequence);

% Rectangular filter 
rectFilter = ones(1, upsampleFactors(3));

% Convolve upsample unipolar sequence with a rectangular filter
convSequence = conv(upsampleSequence, rectFilter);

% Retain just only the value with a upsampleSequence
seqFiltered = convSequence(1:upsSeqLength);

% Generate the White Gaussian Noise with 0 dB variance
whiGauNoise = 1/sqrt(2)*[randn(1,upsSeqLength) + j*randn(1,upsSeqLength)];

% Testing values
moduSignal = 10;

% Add the Noise to the channel
transSignal = moduSignal + 10^(-berdB(1)/20)*whiGauNoise; 
 
% Demodulating the signal and use matched filter
demSignalFilt = conv(transSignal,rectFilter); 

% I need to sample  the demodulated signal filtered 
demSignalSample = 4;

% Extract sequence using hard decision decoding with a threshold value of 0
binSeqDem = real(demSignalSample) > 0;

% Count the bits error
errorBitsValue(1) = length(find([binarySequence - binSeqDem]));

%figure(1)
%plot(timeSequence,upsampleSequence);

% Signal modulated
%%w = sqrt(2*errorBit/bitDuration)*cos(2*pi*carrierFrequency*t); 
