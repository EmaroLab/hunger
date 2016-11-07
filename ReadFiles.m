function [x_set y_set z_set numSamples] = ReadFiles(folder,debugMode)
% function [x_set y_set z_set numSamples] = ReadFiles(folder,debugMode)
%
% -------------------------------------------------------------------------
% Author: Barbara Bruno (dept. DIBRIS, University of Genova, ITALY)
%
% This code is the implementation of the algorithms described in the
% paper "Human motion modeling and recognition: a computational approach".
%
% I would be grateful if you refer to the paper in any academic
% publication that uses this code or part of it.
% Here is the BibTeX reference:
% @inproceedings{Bruno12,
% author = "B. Bruno and F. Mastrogiovanni and A. Sgorbissa and T. Vernazza and R. Zaccaria",
% title = "Human motion modeling and recognition: a computational approach",
% booktitle = "Proceedings of the 8th {IEEE} International Conference on Automation Science and Engineering ({CASE} 2012)",
% address = "Seoul, Korea",
% year = "2012",
% month = "August"
% }
% -------------------------------------------------------------------------
%
% ReadFiles reads the *.txt files generated by the sensing device and
% contained in [folder] and returns the sets of the acceleration values
% (in m/s^2) measured along each of the 3 axes separately in all of the
% files. It also filters them with a median filter to reduce the noise
% coming from the accelerometer. The parameter [debugMode] is a flag to
% indicate whether the function should plot the results (debugMode = 1) or
% not (debugMode = 0). Default option is 1.
%
% Input:
%   folder --> directory containing the sensing device output files to be
%              considered for the analysis
%
% Output:
%   x_set --> acceleration values measured along the x axis in each file
%             at each given time instant (each column corresponds to the
%             x axis of a file)
%   y_set --> acceleration values measured along the y axis in each file
%             at each given time instant (each column corresponds to the
%             y axis of a file)
%   z_set --> acceleration values measured along the z axis in each file
%             at each given time instant (each column corresponds to the
%             z axis of a file)
%   numSamples --> number of sample points measured by the accelerometer in
%                  each file (number of rows in the files, that must be
%                  same for ALL files)
%
% Examples:
%   1) default - plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder);
%
%   2) explicit plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,1);
%
%   3) no plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);

% DEFINE THE VALUE FOR FLAG debugMode
if nargin < 2 || isempty(debugMode)
    debugMode = 1;
end

% READ THE ACCELEROMETER DATA FILES
files = dir([folder,'*.txt']);
numFiles = length(files);
dataFiles = zeros(1,numFiles);
for i=1:1:numFiles
    dataFiles(i) = fopen([folder files(i).name],'r');
    data = fscanf(dataFiles(i),'%d\t%d\t%d\n',[3,inf]);

    % CONVERT THE ACCELEROMETER DATA INTO REAL ACCELERATION VALUES
    % mapping from [0..63] to [-14.709..+14.709]
    noisy_x(:,i) = -14.709 + (data(1,:)/63)*(2*14.709);
    noisy_y(:,i) = -14.709 + (data(2,:)/63)*(2*14.709);
    noisy_z(:,i) = -14.709 + (data(3,:)/63)*(2*14.709);

    % DEBUG: PLOT THE DATA COMING FROM EACH TRIAL
    if (debugMode == 1)
        numSamples = length(noisy_x(:,i));
        time = 1:1:numSamples;
        % noisy signal
        figure,
            subplot(3,1,1);
            plot(time,noisy_x(:,i),'-');
            axis([0 numSamples -19.6133 +19.6133]);
            title(['Trial ',num2str(i),' - Noisy accelerations along the x axis']);
            subplot(3,1,2);
            plot(time,noisy_y(:,i),'-');
            axis([0 numSamples -19.6133 +19.6133]);
            title(['Trial ',num2str(i),' - Noisy accelerations along the y axis']);
            ylabel('acceleration [m/s^2] ');
            subplot(3,1,3);
            plot(time,noisy_z(:,i),'-');
            axis([0 numSamples -19.6133 +19.6133]);
            title(['Trial ',num2str(i),' - Noisy accelerations along the z axis']);
            xlabel('time [samples]');
    end
end

% REDUCE THE NOISE ON THE SIGNALS BY MEDIAN FILTERING
% median filter parameters
n = 3;      % order of the median filter
x_set = medfilt1(noisy_x,n);
y_set = medfilt1(noisy_y,n);
z_set = medfilt1(noisy_z,n);
numSamples = length(x_set(:,1));

% DEBUG: PLOT THE ACCELERATION DATA COMING FROM ALL TRIALS
if (debugMode == 1)
    time = 1:1:numSamples;
    % noisy signal
    figure,
        subplot(3,1,1);
        plot(time,noisy_x,'-');
        axis([0 numSamples -14.709 +14.709]);
        title('Noisy modeling dataset - x axis');
        subplot(3,1,2);
        plot(time,noisy_y,'-');
        axis([0 numSamples -14.709 +14.709]);
        title('Noisy modeling dataset - y axis');
        ylabel('acceleration [m/s^2] ');
        subplot(3,1,3);
        plot(time,noisy_z,'-');
        axis([0 numSamples -14.709 +14.709]);
        title('Noisy modeling dataset - z axis');
        xlabel('time [samples]');
    % clean signal
    figure,
        subplot(3,1,1);
        plot(time,x_set,'-');
        axis([0 numSamples -14.709 +14.709]);
        title('Filtered modeling dataset - x axis');
        subplot(3,1,2);
        plot(time,y_set,'-');
        axis([0 numSamples -14.709 +14.709]);
        title('Filtered modeling dataset - y axis');
        ylabel('acceleration [m/s^2] ');
        subplot(3,1,3);
        plot(time,z_set,'-');
        axis([0 numSamples -14.709 +14.709]);
        title('Filtered modeling dataset - z axis');
        xlabel('time [samples]');
    % frequency spectrum comparison between the noisy and the clean signal
    % coming from median filters of different size (3,5,7,9) - x axis only
    Fs = 32;
    NFFT = 2^nextpow2(numSamples);
    f = Fs/2*linspace(0,1,NFFT/2);
    % filter of size 1 (NO filtering)
    n = 1;
    x1 = medfilt1(noisy_x,n);
    fft_x1 = fft(x1);
    % filter of size 3
    n = 3;
    x3 = medfilt1(noisy_x,n);
    fft_x3 = fft(x3);
    % filter of size 5
    n = 5;
    x5 = medfilt1(noisy_x,n);
    fft_x5 = fft(x5);
    % filter of size 7
    n = 7;
    x7 = medfilt1(noisy_x,n);
    fft_x7 = fft(x7);
    % filter of size 9
    n = 9;
    x9 = medfilt1(noisy_x,n);
    fft_x9 = fft(x9);
    % plot the power spectri of the filtered signals
    figure,
        plot(f,2*abs(fft_x1(1:NFFT/2)),'b');
        hold on;
        plot(f,2*abs(fft_x3(1:NFFT/2)),'g');
        hold on;
        plot(f,2*abs(fft_x5(1:NFFT/2)),'r');
        hold on;
        plot(f,2*abs(fft_x7(1:NFFT/2)),'c');
        hold on;
        plot(f,2*abs(fft_x9(1:NFFT/2)),'m');
        legend('NO filtering','filter n = 3','filter n = 5','filter n = 7','filter n = 9');
        title('Power spectri of filtered acceleration data');
        xlabel('frequency [Hz]');
end