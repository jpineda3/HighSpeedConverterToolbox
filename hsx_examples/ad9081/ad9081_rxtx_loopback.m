clear all; close all;

txSource = 'DMA'; % DMA or DDS

% Test Tx DDS output
uri = 'ip:analog.local';

%% Tx set up
tx = adi.AD9081.Tx('uri',uri);
tx.DataSource = txSource;
tx.NCOEnables = [1,1,1,1];
tx.ChannelNCOGainScales = [0.5,0.5,0.5,0.5];
if strcmpi(txSource,'DDS')
    toneFreq = 45e6;
    scales = 0.5;
    phases = 0;
    tx.DDSFrequencies = repmat(toneFreq,2,4);
    tx.DDSScales = repmat(scales,2,4);
    tx.DDSPhases = [0,0;90000,0].';
    tx();
elseif strcmpi(txSource,'DMA')
    amplitude = 2^15; frequency = 250e6/4;
    swv1 = dsp.SineWave(amplitude, frequency);
    swv1.ComplexOutput = true;
    swv1.SamplesPerFrame = 2^12;
    swv1.SampleRate = 250e6;
    y = swv1();
    tx.EnableCyclicBuffers = 1;
    tx(y);
else
    error('Invalid value of txSource, must be DMA or DDS');
end
pause(1);

%% Rx set up
rx = adi.AD9081.Rx('uri',uri);

%% Run
for k=1:10
    valid = false;
    while ~valid
        [out, valid] = rx();
    end
end
fs = rx.SamplingRate;
rx.release();
tx.release();

%% Plot
nSamp = length(out);
FFTRxData  = fftshift(10*log10(abs(fft(out))));
df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df*2).'/1000;
plot(freqRangeRx, FFTRxData);
xlabel('Frequency (kHz)');ylabel('Amplitude (dB)');grid on;
