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

%From here, we combine track files into one producing a size of around 511647 x 14 matrix with measurements as stated above

eyetrack1 = importdata('eye_tracking_run1.txt');        %Import tracking data in from the directory
eyetrack2 = importdata('eye_tracking_run2.txt');
eyetrack3 = importdata('eye_tracking_run3.txt');

eyetrack_int = [eyetrack1 ; eyetrack2];                    
eyetrack = [eyetrack_int ; eyetrack3];

track = eyetrack(:,1);
[a,~] = size(track);
max_time = track(a, 1);

clear eyetrack1 eyetrack2 eyetrack3 eyetrack_int;

%From here, we import the log files and combine them make a 90 x 4 file that we further reduce to a 90 x 2 to separate timestamps and stimuli type

logrun1 = importdata('log_run1_test.txt');             %Import log data from directory
logrun2 = importdata('log_run2_test.txt');
logrun3 = importdata('log_run3_test.txt');

logrun_int = [logrun1 ; logrun2];
logrun = [logrun_int ; logrun3];

temp_1 = logrun1(:, 3:4);
logtemp1 = temp_1(temp_1 == 1,2);
temp_2 = logrun2(:, 3:4);
logtemp2 = temp_2(temp_2 == 1, 2);
temp_3 = logrun3(:,3:4);
int_temp3 = temp_3(temp_3==1, 2);
logtemp3 = int_temp3(int_temp3 < max_time, :);

[Size1,~] = size(logtemp1);
[Size2,~] = size(logtemp2);
[Size3,~] = size(logtemp3);
%[Run1size, ~] = 
clear logtemp1 logtemp2 logtemp3 logrun_int int_temp3 temp_1 temp_2 temp_3 logrun1 logrun2 logrun3


%From here until line 107, 73 is the size of the log file that is in the domain of the track file, and 74 is used as a boundary for where to stop
%I would like to make the size of the log file more general (i.e. turn the 73's from here til 101 into a variable), but I'm not sure how

%for stimuli1 = 1
    stimulus_t = logrun(:,3:4);            %Only takes the 3rd and 4th column, which contains which stimuli and at what time it was administered
    s1 = stimulus_t(stimulus_t == 1, :);  %Separating the first stimuli and their timestamps from the rest of the log data
%end

%for stimuli2 = 2
    %stimulus_t = logrun(:, 3:4);              %Only takes 3rd and 4th column once again, which contains the type of stimuli administered and the time stamp with it
    s2 = stimulus_t(stimulus_t == 2, :);            %Separates the second stimuli and their timestamps from the rest of the data
%end

clear stimuli1 stimuli2

rounded_s1 = [s1(:,1), round(s1(:,2), 4)];      %We round the 1st stimuli's time stamps to within .1 ms due to resolution of eye-tracking software
rounded_s2 = [s2(:,1), round(s2(:,2), 4)];      %We round the 2nd stimuli's time stamps to within .1 ms due to eye-tracking resolution
        
time_s1 = rounded_s1(:,2);              %We separate the timestamps from the type of stimuli

time_s1_bound = time_s1(time_s1<max_time, 1);                 


rounded_s1_row = time_s1_bound.';             %We rotate the column to make a row of all the time stamps
[~,n] = size(rounded_s1_row);           %We determine the size of this new rotated time-stamp matrix

clear time_s1_bound time_s1 rounded_s1

%Now we move onto determining the times that are closest to the tracking data

%We determine this by finding the minimum of the absolute value of the differences


track_index = 1;
log_track = 1;
mat_s1 = zeros(n,1);       %SPECIFIC, Change "73" to a different number depending on the number of non-false stimuli (either 1 or 2 on the log run file)
count = 1;
for y = rounded_s1_row(:,1):rounded_s1_row(:,n)

    
    current_track = track(track_index,1);
    difference = inf;
   
    
    for track_index = 1:a
        if log_track > n
            done = 'done';
        elseif abs(rounded_s1_row(1,log_track) - track(track_index,1)) < difference && track_index <= a && log_track < n+1      %SPECIFIC, Change 74 to n+1 of the original zeroes size, and change 5113446 to the size of the original timelog file
            count = count +1;
            difference = abs(rounded_s1_row(1,log_track) - track(track_index,1));
            
        
        elseif track_index == a+1        %SPECIFIC, change 511347 to n+1, where n is the size of the entire eye-tracking file
             Error = Happened;
        
        elseif abs(rounded_s1_row(1, log_track) - track(track_index)) >= difference && log_track <= n
                count = count +1;
                mat_s1(log_track, 1) = track_index;
                log_track = log_track + 1;
                difference = inf;
                
        end
    end
end

%From here, I did not put many comments, and the comments that are here were for my notes as I generalized the variables, so ignore them for now

clear a m n h y difference ;
[a,~] = size(mat_s1);
count = 1;
mat_s1_row = mat_s1.';
Matrix2 = zeros(a, 13);        %SPECIFIC , change 73 to the size of the log file


for m = 1 : a
    for n = mat_s1_row(:,1) : mat_s1_row(:,a)
        if count <= a              %SPECIFIC, change 73 to the size of the log file
            Matrix1 = mean(eyetrack(mat_s1(count) : mat_s1(count)+400, 2:14));
            Matrix2(count, :) = Matrix1;
            count = count +1;
        
        elseif count > a           %SPECIFIC, change 73 to the size of the log file
            h = 'DONE';
        end
    end
end

Run1 = Matrix2(1:Size1, :);        %SPECIFIC, Change these numbers to reflect the first log run file
Run2 = Matrix2(Size1+1:Size1+Size2, :);       %SPECIFIC, Change these numbers to reflect the second log run file
Run3 = Matrix2(Size1+Size2+1:Size1+Size2+Size3, :);       %SPECIFIC, Change these numbers to reflect the third log run file
    



    
    

       





    


