function [doppler_fft, range_fft, range_angle] = fft_features_raw(Receiver_1, Receiver_2, Receiver_3, Receiver_4, numADCSamples, sampling_rate, freq_slope, frame, m_chirps, angle_padding_count, range_cut_value)
    
    c = 3e8; %Light speed (m/s)
    sampling_time = numADCSamples / sampling_rate; % Sampling time (s)
    BW = sampling_time * freq_slope; % Bandwidth (Hz)
    range_resolution = c / (2 * BW); % Range Resolution (m)
    f_start = 60e9; % Frequency Start
    
    range_axis = (0:(numADCSamples/range_cut_value)-1) * range_resolution; % Range Axis (m)
    velocity_resolution = c / (2 * f_start * m_chirps * sampling_time); % Velocity Resolution (m/s)
    velocity_axis = (-m_chirps/2:(m_chirps/2-1)) * velocity_resolution; % Velocity Axis (m/s)
    
    Rx1 = Receiver_1(:,frame);
    Rx2 = Receiver_2(:,frame);
    Rx3 = Receiver_3(:,frame);
    Rx4 = Receiver_4(:,frame);
    Rx1 = reshape(Rx1, numADCSamples, 2, m_chirps);
    Rx2 = reshape(Rx2, numADCSamples, 2, m_chirps);
    Rx3 = reshape(Rx3, numADCSamples, 2, m_chirps);
    Rx4 = reshape(Rx4, numADCSamples, 2, m_chirps);
    Rx1_Tx1 = Rx1(:, 1, :);
    Rx2_Tx1 = Rx2(:, 1, :);
    Rx3_Tx1 = Rx3(:, 1, :);
    Rx4_Tx1 = Rx4(:, 1, :);
    Rx1_Tx3 = Rx1(:, 2, :);
    Rx2_Tx3 = Rx2(:, 2, :);
    Rx3_Tx3 = Rx3(:, 2, :);
    Rx4_Tx3 = Rx4(:, 2, :);
    Rx_virtual = [Rx1_Tx1, Rx2_Tx1, Rx3_Tx1, Rx4_Tx1, Rx1_Tx3, Rx2_Tx3, Rx3_Tx3, Rx4_Tx3];

    Rx_virtual_doppler = zeros(8, numADCSamples, m_chirps);

    for cnt = 1:8
        Rx_vt = Rx_virtual(:, cnt, :);
        Rx_vt = reshape(Rx_vt, numADCSamples, m_chirps);
        
        % 1D FFT along the range dimension
        range_fft = fft(Rx_vt, numADCSamples, 1);
        
        % 1D FFT along the Doppler dimension
        doppler_fft = fft(range_fft, [], 2);
        doppler_fft = fftshift(doppler_fft, 2);
        
        Rx_virtual_doppler(cnt, :, :) = doppler_fft;
        
        % Plotting for the first virtual receiver channel
        if cnt == 1       
            figure(1)
            subplot(1, 2, 1);
            imagesc(velocity_axis, range_axis, 20 * log10(abs(doppler_fft(1:numADCSamples/range_cut_value, :))));
            xlabel('velocity in m/s');
            ylabel('range in m');
            title(['FrameID: ' num2str(frame)])
            colorbar
        end
    end
    
    range_angle = zeros(numADCSamples, angle_padding_count);
    for x=1:numADCSamples
        peak_pos = 0;
        peak_Amp = 0;
        for y=1:m_chirps
            amp = abs(Rx_virtual_doppler(1, x, y));
            if amp ~= 0  && y ~= 33
                if peak_Amp < amp
                    peak_Amp = amp;
                    peak_pos = y;
                end
            end
        end
        if peak_Amp ~= 0
            angle_ex = [Rx_virtual_doppler(1, x, peak_pos), Rx_virtual_doppler(2, x, peak_pos), ...
                        Rx_virtual_doppler(3, x, peak_pos), Rx_virtual_doppler(4, x, peak_pos), ...
                        Rx_virtual_doppler(5, x, peak_pos), Rx_virtual_doppler(6, x, peak_pos), ...
                        Rx_virtual_doppler(7, x, peak_pos), Rx_virtual_doppler(8, x, peak_pos)];
            
            % Apply Angle FFT (angle padding)
            angle_ex_fft = fft(angle_ex, angle_padding_count);
            angle_ex_fft = fftshift(angle_ex_fft);                       
            range_angle(x, :) = angle_ex_fft;
        end
    end

    subplot(1, 2, 2);
    x_axis_img = linspace(-60, 60, angle_padding_count);
    imagesc(x_axis_img, range_axis, abs(range_angle(1:numADCSamples/range_cut_value, :)));
    xlabel('angle in degree');
    ylabel ('range in m');
    title(['FrameID:' num2str(frame)])
    colorbar
    clim([0 5*10^5])
    pause(0.05)

end

