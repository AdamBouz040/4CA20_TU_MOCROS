
% 4CBLA20 - TU/e Mocros Assignment
test
fs= 8000 this frequency is for standard for phone numbers (sampling) 
T= 1/fs 
signal duration= 100ms 
Time vector= copy
Idea; Create a code that recognizes a digits of a phone number based on frequency and dft as a bonus it tells you (based on the 1st 3 digits)
From which country its from 
Code; % ============================================================
% ============================================================

clc;
clear;
close all;

%% ============================================================
% PARAMETERS
%% ============================================================

             % Sampling frequency
record_time = 18;        % Recording duration

%% ============================================================
% DTMF FREQUENCIES
%% ============================================================

low_freqs = [697 770 852 941];
high_freqs = [1209 1336 1477];

keys = ['1','2','3';
        '4','5','6';
        '7','8','9';
        '*','0','#'];

%% ============================================================
% RECORD AUDIO
%% ============================================================

disp('========================================');
disp('Play phone keypad tones now...');
disp('Press digits slowly with pauses.');
disp('========================================');

[signal,fs] = audioread('WhatsApp Video 2026-05-28 at 16.39.53.mp4');
if size(signal,2) > 1
    signal = mean(signal, 2);
end

disp('Recording complete.');

%% ============================================================
% NORMALIZE SIGNAL
%% ============================================================

signal = signal ./ max(abs(signal));

%% ============================================================
% PLOT SIGNAL
%% ============================================================

figure;
plot(signal);

title('Recorded DTMF Signal');
xlabel('Samples');
ylabel('Amplitude');

grid on;

%% ============================================================
% DETECT ACTIVE REGIONS
%% ============================================================

threshold = 0.15;

active = abs(signal) > threshold;

% Smooth detection manually
window = 500;

smooth_active = zeros(size(active));

for i = window+1:length(active)-window

    smooth_active(i) = ...
        mean(active(i-window:i+window));

end

active = smooth_active > 0.1;

%% ============================================================
% FIND START/END POINTS
%% ============================================================

diff_signal = diff([0; active; 0]);

start_points = find(diff_signal == 1);
end_points = find(diff_signal == -1);

decoded_number = '';

%% ============================================================
% PROCESS EACH TONE
%% ============================================================

for i = 1:length(start_points)

    start_idx = start_points(i);
    end_idx = end_points(i);

    segment = signal(start_idx:end_idx);

    % Ignore short segments
    if length(segment) < 2000
        continue;
    end

    %% ========================================================
    % FFT
    %% ========================================================

    N = length(segment);

    X = fft(segment);

    magnitude = abs(X);

    freq = (0:N-1)*(fs/N);

    %% ========================================================
    % POSITIVE FREQUENCIES
    %% ========================================================

    halfN = floor(N/2);

    freq_half = freq(1:halfN);
    mag_half = magnitude(1:halfN);

    %% ========================================================
    % SIMPLE PEAK DETECTION
    %% ========================================================

    [sorted_mag, sorted_idx] = sort(mag_half,'descend');

    detected_freqs = freq_half(sorted_idx(1:20));

    detected_freqs = unique(round(detected_freqs));

    %% ========================================================
    % FIND LOW + HIGH FREQUENCIES
    %% ========================================================

    low_candidates = detected_freqs( ...
        detected_freqs > 650 & ...
        detected_freqs < 1000);

    high_candidates = detected_freqs( ...
        detected_freqs > 1100 & ...
        detected_freqs < 1600);

    if isempty(low_candidates) || isempty(high_candidates)
        continue;
    end

    low_freq = low_candidates(1);
    high_freq = high_candidates(1);

    %% ========================================================
    % MATCH TO DTMF TABLE
    %% ========================================================

    [~,row] = min(abs(low_freqs - low_freq));

    [~,col] = min(abs(high_freqs - high_freq));

    digit = keys(row,col);

    decoded_number = [decoded_number digit];

    %% ========================================================
    % DISPLAY RESULTS
    %% ========================================================

    fprintf('\nDetected Digit: %s\n',digit);

    fprintf('Low Frequency : %.2f Hz\n',low_freq);

    fprintf('High Frequency: %.2f Hz\n',high_freq);

    %% ========================================================
    % FFT PLOT
    %% ========================================================

    figure;

    plot(freq_half,mag_half);

    title(['FFT of Digit ',digit]);

    xlabel('Frequency (Hz)');
    ylabel('Magnitude');

    grid on;

end

%% ============================================================
% FINAL OUTPUT
%% ============================================================

fprintf('\n=====================================\n');

fprintf('DETECTED PHONE NUMBER: %s\n',decoded_number);
%% ============================================================
% COUNTRY DETECTION USING TXT FILE
%% ============================================================

fileID = fopen('country_codes.txt','r');

country_found = 'Unknown Country';
country_code_found = '';

while ~feof(fileID)

    line = fgetl(fileID);

    data = strsplit(line, ',');

    code = strtrim(data{1});
    country = strtrim(data{2});

    % Check if number starts with this code
    if startsWith(decoded_number, code)

        country_found = country;
        country_code_found = code;

    end

end

fclose(fileID);

%% DISPLAY COUNTRY

fprintf('\n=====================================\n');

fprintf('Country Code: %s\n',country_code_found);

fprintf('Detected Country: %s\n',country_found);

fprintf('=====================================\n');

fprintf('=====================================\n');

%% ============================================================
% SAVE AUDIO
%% ============================================================

audiowrite('recorded_dtmf.wav',signal,fs);

disp('Audio saved.');

%% ============================================================
% NOISE TEST
%% ============================================================

noise_level = 0.1;

noisy_signal = signal + ...
               noise_level*randn(size(signal));

figure;

plot(noisy_signal);

title('Noisy Signal');

xlabel('Samples');
ylabel('Amplitude');

grid on;

%% ============================================================
% FFT OF FULL SIGNAL
%% ============================================================

N_full = length(signal);

X_full = fft(signal);

mag_full = abs(X_full);

freq_full = (0:N_full-1)*(fs/N_full);

figure;

plot(freq_full(1:N_full/2), ...
     mag_full(1:N_full/2));

title('FFT of Full Recorded Signal');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;
Results? 
- Phone number should be displayed 
- Failure experiments/ modes
- Show 2 dominant frequency peaks 
- FFt spectrum of multiple digits 
- Change noise level and see if recognition accuracy increases 
- Change sampling frequency and look how sensitive the systems is 
- Failure case/ background noise can cause inaccuracy 



X[k]=∑n=0N−1​x[n]e−j2πkn/N the convolution for this part 
x(t)=sin(2πf1​t)+sin(2πf2​t) this is how each dtmf is generated 
After FFT-based digit recognition, the system performs country identification using the first three decoded digits.


