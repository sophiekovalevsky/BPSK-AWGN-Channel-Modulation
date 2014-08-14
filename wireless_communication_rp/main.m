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
binSeqLength = length(binarySequence);

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
eBn0 = [0:12];
eBn0Length = length(eBn0);
eBn0Max = max(eBn0);

% Upsample factors
upsampleFactors = [1:4];
upsFacLength = length(upsampleFactors);

% Carrier frequency
carrierFrequency = 50;

% Run for every unsampled factors
for upsFacIndex = 1:upsFacLength
	% Upsample the unipolar sequence and get the vector length
	upsampleSequence = upsample(bipolarSequence, upsampleFactors(upsFacIndex));
	upsSeqLength = length(upsampleSequence);

	% Rectangular filter 
	rectFilter = ones(1, upsampleFactors(upsFacIndex));

	% Convolve upsample unipolar sequence with a rectangular filter
	convSequence = 1/sqrt(upsampleFactors(upsFacIndex))*conv(upsampleSequence, rectFilter);

	% Retain just only the value with a upsampleSequence
	seqFiltered = convSequence(1:upsSeqLength);

	% Generate the White Gaussian Noise with 0 dB variance
	whiGauNoise = 1/sqrt(2)*[randn(1,upsSeqLength) + j*randn(1,upsSeqLength)];

	% Testing values
	moduSignal = seqFiltered;

	% Signal modulated
	%moduSignal = sqrt(2*errorBit/bitDuration)*cos(2*pi*carrierFrequency*t);


	% Run for every eBn0
	for eBn0Index = 1:eBn0Length
		% Add the Noise to the channel
		transSignal = moduSignal + 10^(-eBn0(eBn0Index)/20)*whiGauNoise; 
		 
		% Demodulating the signal and use matched filter
		demSignalFilt = conv(transSignal,rectFilter); 

		% I need to sample  the demodulated signal filtered 
		demSignalSample = demSignalFilt(upsampleFactors(upsFacIndex):upsampleFactors(upsFacIndex):upsSeqLength); 

		% Extract sequence using hard decision decoding with a threshold value of 0
		binSeqDem = real(demSignalSample) > 0;

		% Count the bits error
		errorBitsValue(eBn0Index) = length(find([binarySequence - binSeqDem]));
	end

	% Get the simulated BER
	berSimulated(upsFacIndex,:) = errorBitsValue./binSeqLength; 

	% Get the theorical BER
	berTheory = 0.5*erfc(sqrt(10.^(eBn0/10)));

	% Show figure of the differents BER vs AWGN Channel for every upsample factor
	figure
	semilogy(eBn0,berTheory,'rs-','Linewidth',2);
	hold on
	semilogy(eBn0,berSimulated(upsFacIndex,:),'bx-','Linewidth',2);
	grid on
	axis([0 eBn0Max 10^-8 0.1])
	legend('Teórico', 'Simulado');
	xlabel('Eb/N0, dB');
	ylabel('BER');
	title('BER en función de Eb/N0 en canal AWGN');

end 

