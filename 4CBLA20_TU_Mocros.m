
% 4CBLA20 - TU/e Mocros Assignment
test
fs= 8000 this frequency is for standard for phone numbers (sampling) 
T= 1/fs 
signal duration= 100ms 
Time vector= copy
Idea; Create a code that recognizes a digits of a phone number based on frequency and dft as a bonus it tells you (based on the 1st 3 digits)
From which country its from 
Code; % ============================================================
% DTMF PHONE NUMBER RECOGNITION USING FFT / DFT
% Signals and Systems Project
% ============================================================
%
% This project:
% 1. Generates DTMF tones for phone digits
% 2. Combines them into a phone number
% 3. Uses FFT to detect frequencies
% 4. Decodes the phone number automatically
%
% ============================================================

clc;
clear;
close all;

%% ============================================================
% PARAMETERS
%% ============================================================

fs = 8000;              % Sampling frequency
tone_duration = 0.5;    % Tone duration (seconds)
pause_duration = 0.1;   % Pause between digits

%% ============================================================
% DTMF FREQUENCY TABLE
%% ============================================================

DTMF.low = [697 770 852 941];
DTMF.high = [1209 1336 1477];

keys = ['1','2','3';
        '4','5','6';
        '7','8','9';
        '*','0','#'];

%% ============================================================
% INPUT PHONE NUMBER
%% ============================================================

phone_number = '52791';

disp(['Generating tones for number: ', phone_number]);

%% ============================================================
% GENERATE DTMF SIGNAL
%% ============================================================

full_signal = [];

for k = 1:length(phone_number)

    digit = phone_number(k);

    % Find row and column of digit
    [row,col] = find(keys == digit);

    f1 = DTMF.low(row);
    f2 = DTMF.high(col);

    % Generate time vector
    t = 0:1/fs:tone_duration;

    % Generate DTMF tone
    signal = sin(2*pi*f1*t) + sin(2*pi*f2*t);

    % Append tone
    full_signal = [full_signal signal];

    % Add pause
    full_signal = [full_signal ...
                   zeros(1, round(pause_duration*fs))];
end

%% ============================================================
% PLAY SIGNAL
%% ============================================================

disp('Playing DTMF tones...');
sound(full_signal, fs);

%% ============================================================
% PLOT COMPLETE SIGNAL
%% ============================================================

figure;
plot(full_signal);

title('DTMF Phone Number Signal');
xlabel('Samples');
ylabel('Amplitude');

grid on;

%% ============================================================
% SPECTROGRAM
%% ============================================================

figure;
spectrogram(full_signal,256,200,512,fs,'yaxis');

title('Spectrogram of DTMF Signal');

%% ============================================================
% SPLIT SIGNAL INTO DIGITS
%% ============================================================

samples_per_digit = round((tone_duration + pause_duration)*fs);

decoded_number = '';

%% ============================================================
% FFT DECODING
%% ============================================================

for k = 1:length(phone_number)

    % Extract one digit segment
    start_index = (k-1)*samples_per_digit + 1;

    end_index = start_index + ...
                round(tone_duration*fs) - 1;

    segment = full_signal(start_index:end_index);

    %% FFT
    N = length(segment);

    X = fft(segment,N);

    freq = (0:N-1)*fs/N;

    magnitude = abs(X);

    %% Use only positive frequencies
    halfN = floor(N/2);

    freq_half = freq(1:halfN);
    mag_half = magnitude(1:halfN);

    %% Find Peaks
    [pks,locs] = findpeaks(mag_half,...
                           'MinPeakHeight',max(mag_half)/4);

    detected_freqs = freq_half(locs);

    %% Find closest DTMF frequencies
    low_detected = detected_freqs(detected_freqs < 1000);
    high_detected = detected_freqs(detected_freqs > 1000);

    if isempty(low_detected) || isempty(high_detected)
        continue;
    end

    low_freq = low_detected(1);
    high_freq = high_detected(1);

    %% Match frequencies
    [~,row_index] = min(abs(DTMF.low - low_freq));

    [~,col_index] = min(abs(DTMF.high - high_freq));

    %% Decode digit
    digit_detected = keys(row_index,col_index);

    decoded_number = [decoded_number digit_detected];

    %% Display frequencies
    fprintf('\nDigit %d\n',k);

    fprintf('Detected Low Frequency: %.2f Hz\n', ...
             low_freq);

    fprintf('Detected High Frequency: %.2f Hz\n', ...
             high_freq);

    fprintf('Decoded Digit: %s\n',digit_detected);

    %% Plot FFT of each digit
    figure;

    plot(freq_half,mag_half);

    title(['FFT of Digit ',digit_detected]);

    xlabel('Frequency (Hz)');
    ylabel('Magnitude');

    grid on;

end

%% ============================================================
% FINAL RESULT
%% ============================================================

fprintf('\n=================================\n');

fprintf('Original Number : %s\n',phone_number);

fprintf('Decoded Number  : %s\n',decoded_number);

fprintf('=================================\n');

%% ============================================================
% NOISE ROBUSTNESS TEST
%% ============================================================

noise_level = 0.2;

noisy_signal = full_signal + ...
               noise_level*randn(size(full_signal));

%% Plot noisy signal
figure;

plot(noisy_signal);

title('Noisy DTMF Signal');

xlabel('Samples');
ylabel('Amplitude');

grid on;

%% FFT of noisy signal
N_noise = length(noisy_signal);

Y_noise = fft(noisy_signal);

freq_noise = (0:N_noise-1)*fs/N_noise;

mag_noise = abs(Y_noise);

%% Plot noisy FFT
figure;

plot(freq_noise(1:N_noise/2), ...
     mag_noise(1:N_noise/2));

title('FFT of Noisy DTMF Signal');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

Results? 
- Phone number should be displayed 
- Failure experiments/ modes
- Show 2 dominant frequency peaks 
- FFt spectrum of multiple digits 
- Change noise level and see if recognision accuracy increases 
- Change sampling frequency and look how sensitive the systems is 
- Failure case/ background noise 


grid on;
