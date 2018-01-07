% Data is as follow in the bufferData
% timetag : bufferData(:,1)
% left_raw_x : bufferData(:,2)
% left_raw_y : bufferData(:,3)
% leftPP_hori : bufferData(:,4)
% leftPP_vert : bufferData(:,5)
% left_angle : bufferData(:,6)
% right_raw_x : bufferData(:,7)
% right_raw_y : bufferData(:,8)
% rightPP_hori : bufferData(:,9)
% rightPP_vert : bufferData(:,10)
% right_angle : bufferData(:,11)
% Digital Input values : bufferData(:,12)
% blink_left : bufferData(:,13)
% blink_right : bufferData(:,14)

clear                   %Clears Workspace to see differences
format long g           %To generate numbers in regular standard form, rather than exponential

%******************Part 1: Importing Data files*******************

eyetrack1 = importdata('eye_tracking_run1.txt');        %Import tracking data in from the directory
eyetrack2 = importdata('eye_tracking_run2.txt');
eyetrack3 = importdata('eye_tracking_run3.txt');

eyetrack_int = [eyetrack1 ; eyetrack2];        %Concatenating all of the track data into one matrix            
eyetrack = [eyetrack_int ; eyetrack3];

track = eyetrack(:,1);
[track_size,~] = size(track);
max_time = track(track_size, 1);             %Determining the largest time the track file goes up to

clear eyetrack1 eyetrack2 eyetrack3 eyetrack_int;

%From here, we import the log files and combine them make a 90 x 4 file that we further reduce to a 90 x 2 to separate timestamps and stimuli type

logrun1 = importdata('log_run1_test.txt');             %Import log data from directory
logrun2 = importdata('log_run2_test.txt');
logrun3 = importdata('log_run3_test.txt');

logrun_int = [logrun1 ; logrun2];                   %Concatenating the log files into one matrix
logrun = [logrun_int ; logrun3];

clear logrun_int

%******************Part 2a: Determining Sizes of the "1" Stimuli Runs*******************

s1_temp_1 = logrun1(:, 3:4);                         %Creates "1" stimuli matrices for each run, which is necessary for determining size
s1_logtemp1 = s1_temp_1(s1_temp_1 == 1,2);
s1_temp_2 = logrun2(:, 3:4);
s1_logtemp2 = s1_temp_2(s1_temp_2 == 1, 2);
s1_temp_3 = logrun3(:,3:4);                          %The last run is different, as the times might not match up, so it will determine which timestamps are within the time range of the track file
s1_int_temp3 = s1_temp_3(s1_temp_3 == 1, 2);
s1_logtemp3 = s1_int_temp3(s1_int_temp3 < max_time, :);

[s1_Size1,~] = size(s1_logtemp1);                       %Determines the size of each of these runs to be used in Part 5a
[s1_Size2,~] = size(s1_logtemp2);
[s1_Size3,~] = size(s1_logtemp3);
 
clear s1_logtemp1 s1_logtemp2 s1_logtemp3 s1_logrun_int s1_int_temp3 s1_temp_1 s1_temp_2 s1_temp_3 

%******************Part 2b: Determining Sizes of the "2" Stimuli Runs*******************

s2_temp_1 = logrun1(:, 3:4);                         %Creates "2" stimuli matrices for each run, which is necessary for determining size
s2_logtemp1 = s2_temp_1(s2_temp_1 == 2,2);
s2_temp_2 = logrun2(:, 3:4);
s2_logtemp2 = s2_temp_2(s2_temp_2 == 2, 2);
s2_temp_3 = logrun3(:,3:4);                          %The last run is different, as the times might not match up, so it will determine which timestamps are within the time range of the track file
s2_int_temp3 = s2_temp_3(s2_temp_3 == 2, 2);
s2_logtemp3 = s2_int_temp3(s2_int_temp3 < max_time, :);

[s2_Size1,~] = size(s2_logtemp1);                       %Determines the size of each of these runs to be used in Part 5b
[s2_Size2,~] = size(s2_logtemp2);
[s2_Size3,~] = size(s2_logtemp3);
 
clear s2_logtemp1 s2_logtemp2 s2_logtemp3 s2_logrun_int s2_int_temp3 s2_temp_1 s2_temp_2 s2_temp_3 

%******************Part 3a: Separating the "1" Stimuli Timestamps*******************

stimulus_t = logrun(:,3:4);                     %Only takes the 3rd and 4th column, which contains which stimuli and at what time it was administered
s1 = stimulus_t(stimulus_t == 1, :);            %Separating the first stimuli and their timestamps from the rest of the log data
rounded_s1 = [s1(:,1), round(s1(:,2), 4)];      %We round the 1st stimuli's time stamps to within .1 ms due to resolution of eye-tracking software
time_s1 = rounded_s1(:,2);                      %We separate the timestamps from the type of stimuli
time_s1_bound = time_s1(time_s1<max_time, 1);                 
rounded_s1_row = time_s1_bound.';               %We rotate the column to make a row of all the time stamps
[~,s1_size] = size(rounded_s1_row);             %We determine the size of this new rotated time-stamp matrix
clear time_s1_bound time_s1 rounded_s1

%******************Part 3b: Separating the "2" Stimuli Timestamps*******************

s2 = stimulus_t(stimulus_t == 2, :);            %Separates the second stimuli and their timestamps from the rest of the data
rounded_s2 = [s2(:,1), round(s2(:,2), 4)];      %We round the 2nd stimuli's time stamps to within .1 ms due to eye-tracking resolution
time_s2 = rounded_s2(:,2);
time_s2_bound = time_s2(time_s2<max_time, 1);
rounded_s2_row = time_s2_bound.';
[~, s2_size] = size(rounded_s2_row);
clear time_s2_bound time_s2 rounded_s2

%******************Part 4a: Searching for Track Times that are nearest the "1" Stimuli Timestamps*******************

%We determine this by finding the minimum of the absolute value of the differences

track_index = 1;
log_track = 1;
mat_s1 = zeros(s1_size,1);       %SPECIFIC, Change "73" to a different number depending on the number of non-false stimuli (either 1 or 2 on the log run file)
count = 1;
for y = rounded_s1_row(:,1):rounded_s1_row(:,s1_size)
    current_track = track(track_index,1);
    difference = inf;
   
    for track_index = 1:track_size
        if log_track > s1_size
            S1_Time_Completion = 'Done';
            
        elseif abs(rounded_s1_row(1,log_track) - track(track_index,1)) < difference && track_index <= track_size && log_track < s1_size+1      %SPECIFIC, Change 74 to n+1 of the original zeroes size, and change 5113446 to the size of the original timelog file
            count = count +1;
            difference = abs(rounded_s1_row(1,log_track) - track(track_index,1));
        
        elseif abs(rounded_s1_row(1, log_track) - track(track_index)) >= difference && log_track <= s1_size
                count = count +1;
                mat_s1(log_track, 1) = track_index;
                log_track = log_track + 1;
                difference = inf;
                
        elseif track_index == track_size+1        %SPECIFIC, change 511347 to n+1, where n is the size of the entire eye-tracking file
             Error_Part4a = Happened;
             
        end
    end
end
clear difference rounded_s1_row log_track logrun1 logrun2 logrun3 count track_index

%******************Part 4b: Searching for Track Times that are nearest the "2" Stimuli Timestamps*******************

track_index = 1;
log_track = 1;
mat_s2 = zeros(s2_size,1);       %SPECIFIC, Change "73" to a different number depending on the number of non-false stimuli (either 1 or 2 on the log run file)
count = 1;
for y = rounded_s2_row(:,1):rounded_s2_row(:,s2_size)
    current_track = track(track_index,1);
    difference = inf;
   
    for track_index = 1:track_size
        if log_track > s2_size
            S2_Time_Completion = 'Done';
            
        elseif abs(rounded_s2_row(1,log_track) - track(track_index,1)) < difference && track_index <= track_size && log_track < s2_size+1      %SPECIFIC, Change 74 to n+1 of the original zeroes size, and change 5113446 to the size of the original timelog file
            count = count +1;
            difference = abs(rounded_s2_row(1,log_track) - track(track_index,1));
        
        elseif abs(rounded_s2_row(1, log_track) - track(track_index)) >= difference && log_track <= s2_size
                count = count +1;
                mat_s2(log_track, 1) = track_index;
                log_track = log_track + 1;
                difference = inf;
                
        elseif track_index == track_size+1        %SPECIFIC, change 511347 to n+1, where n is the size of the entire eye-tracking file
             Error_Part4b = Happened;
             
        end
    end
end
clear difference rounded_s2_row log_track logrun count track_index

%******************Part 5a: Averaging the "1" Stimuli Data and putting it into Separate Run Matrices*******************

count = 1;
mat_s1_row = mat_s1.';
Average_all_s1 = zeros(s1_size, 13);        %SPECIFIC , change 73 to the size of the log file

for m = 1 : s1_size
    for n = mat_s1_row(:,1) : mat_s1_row(:,s1_size)
        if count <= s1_size              %SPECIFIC, change 73 to the size of the log file
            S1_Temp_mat = mean(eyetrack(mat_s1(count) : mat_s1(count)+400, 2:14));
            Average_all_s1(count, :) = S1_Temp_mat;
            count = count +1;
        
        elseif count > s1_size           %SPECIFIC, change 73 to the size of the log file
            S1_Averages_Completion = 'Done';
            
        end
    end
end
clear S1_Temp_mat count 

s1_Run1 = Average_all_s1(1:s1_Size1, :);        %SPECIFIC, Change these numbers to reflect the first log run file
s1_Run2 = Average_all_s1(s1_Size1+1:s1_Size1+s1_Size2, :);       %SPECIFIC, Change these numbers to reflect the second log run file
s1_Run3 = Average_all_s1(s1_Size1+s1_Size2+1:s1_Size1+s1_Size2+s1_Size3, :);       %SPECIFIC, Change these numbers to reflect the third log run file

clear s1_Size1 s1_Size2 s1_Size3 

%******************Part 5b: Averaging the "2" Stimuli Data and putting it into Separate Run Matrices*******************

count = 1;
mat_s2_row = mat_s2.';
Average_all_s2 = zeros(s2_size, 13);        %SPECIFIC , change 73 to the size of the log file

for m = 1 : s2_size
    for n = mat_s2_row(:,1) : mat_s2_row(:,s2_size)
        if count <= s2_size              %SPECIFIC, change 73 to the size of the log file
            S2_Temp_mat = mean(eyetrack(mat_s2(count) : mat_s2(count)+400, 2:14));
            Average_all_s2(count, :) = S2_Temp_mat;
            count = count +1;
        
        elseif count > s2_size           %SPECIFIC, change 73 to the size of the log file
            S2_Averages_Completion = 'Done';
            
        end
    end
end
clear S2_Temp_mat count 

s2_Run1 = Average_all_s2(1:s2_Size1, :);        %SPECIFIC, Change these numbers to reflect the first log run file
s2_Run2 = Average_all_s2(s2_Size1+1:s2_Size1+s2_Size2, :);       %SPECIFIC, Change these numbers to reflect the second log run file
s2_Run3 = Average_all_s2(s2_Size1+s2_Size2+1:s2_Size1+s2_Size2+s2_Size3, :);       %SPECIFIC, Change these numbers to reflect the third log run file

clear s2_Size1 s2_Size2 s2_Size3
