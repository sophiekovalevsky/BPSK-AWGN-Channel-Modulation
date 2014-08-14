% Generate a binary sequence Pr(0) = 0.5 and Pr(1) = 0.5
binarySequence = rand(1,10)>0.5;

% Convert binary sequence to bipolar sequence
unipolarSequence = 2*binarySequence-1;

% Discrete time sequence bettwen 0 and 10*T with 1000 sampltes
timeSequence = linspace(0,5,1000);

% Bit duration
bitDuration = 1; 

% Error bit used to normalized the amplitude of the signal
erroBit = bitDuration/2;

% Carrier frequency
carrierFrequency = 50;

% Upsample the unipolar sequence 

upsampleSequence = upsample(unipolarSequence,100)

figure(1)
plot(timeSequence,upsampleSequence);

% Signal modulated
%%w = sqrt(2*errorBit/bitDuration)*cos(2*pi*carrierFrequency*t); 