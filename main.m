%% Settings
clear;
% Radar Config
numADCSamples = 256; % number of ADC samples per chirp
numTX = 2; % number of transmitters, fixed with 2 in this code
numRX = 4; % number of receivers
numLanes = 2; % do not change. number of lanes is always 2
isReal = 0; % set to 1 if real only data, 0 if complex data0
sampling_rate = 9121 * 10^3; % ADC Sampling Rate (Hz)
freq_slope = 63.343 * 10^6; % Frequency Slope (Hz/s)
frames=200;

% Read .bin file
fid = fopen("Dataset\1106_cross.bin",'r');
% Set file name of output .gif file
outputname = "output.gif";
adcData = fread(fid, 'int16');

% Set angle padding size
angle_padding_count = 128;

%% read file
[retVal] = readFile(adcData, numADCSamples, numTX, numRX, isReal);
fclose(fid);

%% Data Processing
Receiver_1= retVal(1,:); 
Receiver_2= retVal(2,:);
Receiver_3= retVal(3,:);
Receiver_4= retVal(4,:);

s=size(Receiver_2,2)/frames;
m_chirps=s/numADCSamples/2;
Receiver_1=reshape(Receiver_1,s,frames);
Receiver_2=reshape(Receiver_2,s,frames);
Receiver_3=reshape(Receiver_3,s,frames);
Receiver_4=reshape(Receiver_4,s,frames);

%% Calculate and Visualization

for frame=1:frames
    
    [doppler_fft, range_fft, range_angle] = fft_features(Receiver_1, Receiver_2, Receiver_3, Receiver_4, numADCSamples,...
                                                          sampling_rate, freq_slope, frame, m_chirps, angle_padding_count);

    % Save the image as a .gif file

    % frm = getframe(1);
    % img = frame2im(frm);
    % [imind, cm] = rgb2ind(img, 256);
    % 
    % if frame == 1
    %     % Make gif File
    %     imwrite(imind, cm, outputname, 'gif', 'Loopcount', 1, 'DelayTime', 0.1);
    % else
    %     imwrite(imind, cm, outputname, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    % end

end
