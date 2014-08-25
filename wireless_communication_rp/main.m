% Clear all variables
% Close all figures

clear all;
close all;
 
% % Generate a binary sequence Pr(0) = 0.5 and Pr(1) = 0.5
% binarySequence = rand(1,10e5)>0.5;
% binSeqLength = 10e5;

% Load binary sequence from binary_sequence.mat
sequenceStructure = load('binary_sequence');

% Extract binary sequence fields
binarySequence = cell2mat(extractfield(sequenceStructure, 'ip'));
binSeqLength = length(binarySequence);

% Convert binary sequence to bipolar sequence
bipolarSequence = 2*binarySequence-1;

% Bit duration in us
bitDuration = 1; 

% Sample frequency assigned by the assistant in MHz
sampleFrequency = 5/bitDuration;

% Duration of signal to generate in us
T = bitDuration*binSeqLength;

% Values to BER in dB
eBn0 = [0:12];
eBn0Length = length(eBn0);
eBn0Max = max(eBn0);

% Upsample factors
upsampleFactors = [1:4];
upsFacLength = length(upsampleFactors);

% Run for every unsampled factors
for upsFacIndex = 1:upsFacLength

	% Discrete time sequence
	timeSequence = 1/(upsFacIndex*sampleFrequency):1/(upsFacIndex*sampleFrequency):T;
	timSeqLength = length(timeSequence);

	% Bipolar signal sampled
	bipolarSampled = kron(bipolarSequence,ones(1,sampleFrequency));

	% Upsample the unipolar sequence and get the vector length
	upsampleSequence = upsample(bipolarSampled, upsampleFactors(upsFacIndex));
	upsSeqLength = length(upsampleSequence);

	% Rectangular filter 
	rectFilter = ones(1, upsampleFactors(upsFacIndex));

	% Convolve upsample unipolar sequence with a rectangular filter
	convSequence = 1/sqrt(upsampleFactors(upsFacIndex))*conv(upsampleSequence,rectFilter);

	% Retain just only the value with a upsampleSequence
	seqFiltered = convSequence(1:upsSeqLength);

	% Generate the White Gaussian Noise with 0 dB variance
	whiGauNoise = 1/sqrt(2)*randn(1,upsSeqLength);

	% Send the sequence filtered as a modulated signal
	moduSignal = seqFiltered;

	% Run for every eBn0
	for eBn0Index = 1:eBn0Length
		% Add the Noise to the channel
		transSignal = moduSignal + 10^(-eBn0(eBn0Index)/20)*whiGauNoise; 
		 
		% Demodulating the signal and use matched filter
		demSignalFilt = conv(transSignal,rectFilter); 

		% I need to sample  the demodulated signal filtered 
		demSignalSample = demSignalFilt(upsampleFactors(upsFacIndex)*sampleFrequency:upsampleFactors(upsFacIndex)*sampleFrequency:upsSeqLength);

		% Extract sequence using hard decision decoding with a threshold value of 0
		binSeqDem = demSignalSample > 0;

		% Count the bits error
		errorBitsValue(eBn0Index) = length(find([binarySequence - binSeqDem]));
	end

	% Get the simulated BER
	berSimulated(upsFacIndex,:) = errorBitsValue./binSeqLength; 

	% Get the theorical BER
	berTheory = 0.5*erfc(sqrt(10.^(eBn0/10)));
    
    % Length of the power spectral density
    lengthPSD = 2048;

    % Get the power spectral density
    signalPSD = pwelch(moduSignal,[],[],lengthPSD,sampleFrequency,'twosided');
    
    % Set the dc component to the origin and the PSD Watts/Hz into dB/Hz
    signalPsdCentered = 10*log10(fftshift(signalPSD));
    
    % Create the frequency vector to plot the PSD
    freVector = [-lengthPSD/2:(lengthPSD-1)/2]*sampleFrequency/lengthPSD;
        
	% Show figure of the differents BER vs AWGN Channel for every upsample factor
	figure
	semilogy(eBn0,berTheory,'rs-','Linewidth',2);
	hold on
	semilogy(eBn0,berSimulated(upsFacIndex,:),'bx-','Linewidth',2);
	grid on
	axis([0 6 10^-3 0.1])
	legend('Teórico', 'Simulado');
	xlabel('Eb/N0 (dB)');
	ylabel('BER');
	title('BER en función de Eb/N0 en canal AWGN');
	    
	    % Show figure of PSD signal modulated
	    figure
	    plot(freVector,signalPsdCentered,'k','LineWidth',2);
	    grid on
	    axis([-1.5 1.5 -62 5])
	    xlabel('Frecuencia (MHz)');
	    ylabel('Densidad espectral de potencia (dB/Hz)');
	    title('PSD vs Frecuencia para Tb = 1\mus');
end 

