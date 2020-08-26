%%% NEURAL DATA ANALYSIS FOR EN1 COLLABORATION PROJECT WITH NATE ACHILLY
%%% FROM ZOGHBI LAB.
%%% This code pulls recording data collected by Olivia Kim from 1 WT and 1
%%% mutant animal.

close all
clear all

    
files = {
    'C:\olivia\data\ephys\N085\N085_180124_t02_1050.mat',...
    'C:\olivia\data\ephys\N085\N085_180124_t03_2500.mat',...
    'C:\olivia\data\ephys\N085\N085_180125_t01_1600.mat',...
    'C:\olivia\data\ephys\N085\N085_180125_t02_1700.mat',...
    'C:\olivia\data\ephys\N085\N085_180125_t02_1850.mat',...
    'C:\olivia\data\ephys\N085\N085_180125_t03_2300_2.mat',...
    'C:\olivia\data\ephys\N087\N087_180306_t04_0900_ch1.mat',...
    'C:\olivia\data\ephys\N087\N087_180306_t04_2000.mat',...
    'C:\olivia\data\ephys\N087\N087_180306_t05_2150.mat',...
    'C:\olivia\data\ephys\N087\N087_180306_t06_2000.mat',...
    'C:\olivia\data\ephys\N087\N087_180306_t06_2075.mat'
    };
    %'C:\olivia\data\N085\N085_180124_t03_1900.mat',... % this cell is unhealthy

data.filename = {};
data.ssFR = [];
data.cspkFR = [];
data.ssCV = [];
data.ssCV2 = {};
data.cspkCV = [];
data.cspkCV2 = {};
data.recDur = [];

for f = 1:length(files)
    load(files{f});
    data.filename{f,1} = files{f};
    
    %% index the SS and CSpks based on sorting notes
    % nw_17.codes(:,1) meanings (determined by OK during sorting)
    if strcmp(files{f},'C:\olivia\data\ephys\N085\N085_180124_t02_1050.mat')
        % 1 - SS triggered on falling phase
        % 2 - CSpk triggered on something weird
        % 3 - CSpk triggered on falling phase
        % 4 - CSpk triggered on rising phase
        % 5 - SS triggered on some pre-spike component
        % 6 - garbage
        % 7 - SS triggered on rising phase
        % 8 - SS triggered on some prespike component
        % 9 - SS followed by CSpk
        % 0A - ?
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==5 | nw_17.codes(:,1)==7 ...
            | nw_17.codes(:,1)==8 | nw_17.codes(:,1)==9;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==3 | nw_17.codes(:,1)==4;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==9;
        cspkTimes_missed = [];
        exclude = [];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
%     elseif strcmp(files{f},'C:\olivia\data\N085\N085_180124_t03_1900.mat')
%         % CONSIDER EXCLUDING FOR INJURY, OR MAYBE EXCLUDE MORE UNHEALTHY
%         % PARTS WITH BIG PAUSES?
%         
%         % 1 - SS triggered on falling phase
%         % 2 - CSpk triggered on rising phase
%         % 3 - CSpk triggered on rising phase with spikelet
%         % 4 - CSpk triggered on falling phase
%         % 5 - spikelet
%         % 6 - SS followed by CSpk
%         
%         ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==6;
%         cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==3 | nw_17.codes(:,1)==4;
%         cspkIdx_butAdd800 = nw_17.codes(:,1)==6;
%         cspkTimes_missed = [193.7485; 319.5888; 355.023; 355.497; 368.2137; 400.4875; 410.883];
%         exclude = [27.00,45.00;... % each row of this array represents a block of time that should be excluded (col 1 is start of block, col 2 is end of block)
%                    87.7,135.7];
%         
%         ssIdx_2 = [];
%         cspkIdx_2 = [];
%         cspkIdx_butAdd800_2 = [];
%         cspkTimes_missed_2 = [];

    elseif strcmp(files{f},'C:\olivia\data\ephys\N085\N085_180124_t03_2500.mat')
       
        % 1 - SS triggered on falling phase
        % 2 - CSpk
        % 3 - spikelets
        % 4 - garbage
        % 5 - SS followed by CSpk
        % 6 - CSpk triggered on rising phase
        % 7 - SS triggered on something weird
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==5 | nw_17.codes(:,1)==7;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==6;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==5;
        cspkTimes_missed = [];
        exclude = [84,147.45;... % each row of this array represents a block of time that should be excluded (col 1 is start of block, col 2 is end of block)
                   186.3,nw_17.times(end)];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];    
        
    elseif strcmp(files{f},'C:\olivia\data\ephys\N085\N085_180125_t01_1600.mat')
        % 1 = SS
        % 2 = CSpk triggered on rising phase
        % 3 = CSpk triggered on falling phase
        % 4 = SS followed by CSpk (for simplification, adding a CSpk marker
        %     0.8 s after the SS marker, this won't give a perfect CSpk
        %     timestamp but should be enough for preliminary analysis)
        % 5 = SS triggered on garbage
        % 6 = garbage or spikelet
        % 7 = CSpk triggered on garbage
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==4 | nw_17.codes(:,1)==5;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==3 | nw_17.codes(:,1)==7;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==4;
        cspkTimes_missed = [];
        exclude = []; 
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
    elseif strcmp(files{f}, 'C:\olivia\data\ephys\N085\N085_180125_t02_1700.mat')
        % 1 - ss triggered on prespike rising phase
        % 2 - ss triggered on falling phase
        % 3 - spikelet
        % 4 - cspk triggered on pretrough rising phase phase
        % 5 - cspk triggered on posttrough rising phase
        % 6 - ss triggered on noise
        % 7 - SS foloowed by CSpk
        % 8 - noise
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==2 | nw_17.codes(:,1)==6 | nw_17.codes(:,1)==7;
        cspkIdx = nw_17.codes(:,1)==4 | nw_17.codes(:,1)==5;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==7;
        cspkTimes_missed = [77.070;113.2858;129.185];
        exclude = [];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
    elseif strcmp(files{f},'C:\olivia\data\ephys\N085\N085_180125_t02_1850.mat')
        % nw_17
        % 1 - SS
        % 2 - CSpk triggered on rising phase
        % 3 - spikelet
        % 4 - CSpk triggered on falling phase
        % 5 - SS followed by CSpk
        
        % nw_17_2
        % 1 - SS
        % 2 - CSpk triggered on rising phase
        % 3 - spikelet
        % 4 - SS followed by CSpk
        % 5 - garbage
        % 6 - garbage followed by SS
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==5;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==4;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==5;
        cspkTimes_missed = [];
        exclude = [];
        
        ssIdx_2 = nw_17_2.codes(:,1)==1 | nw_17_2.codes(:,1)==4 | nw_17_2.codes(:,1)==6;
        cspkIdx_2 = nw_17_2.codes(:,1)==2;
        cspkIdx_butAdd800_2 = nw_17.codes(:,1)==4;
        cspkTimes_missed_2 = [228.960; 229.380; 276.321; 280.755];
    elseif strcmp(files{f},'C:\olivia\data\ephys\N085\N085_180125_t03_2300_2.mat')
        % 1 - CSpk triggered on falling phase
        % 2 - SS
        % 3 - CSpk triggered on rising phase
        % 4 - SS triggered on prespike rising phase
        % 5 - garbage
        % 6 - CSpk triggered on garbage
        % 7 - SS triggered on garbage
        % 8 - CSpk triggered on Ca2+ component
        % 9 - SS followed by CSpk
        
        ssIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==4 | nw_17.codes(:,1)==7 |...
            nw_17.codes(:,1)==9;
        cspkIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==3 | nw_17.codes(:,1)==6 |...
            nw_17.codes(:,1)==8;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==9;
        cspkTimes_missed = [];
        exclude = [];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
    elseif strcmp(files{f},'C:\olivia\data\ephys\N087\N087_180306_t04_0900_ch1.mat')
        % 1 - SS
        % 2 - CSpk triggered on falling phase
        % 3 - CSpk triggered on rising phase
        % 4 - SS followed by CSpk
        % 5 - CSpk triggered on CA2+ transient
        % 6 - SS triggered on weird early bumo
        % 7 - garbage
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==4 | nw_17.codes(:,1)==6;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==3 | nw_17.codes(:,1)==5;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==4;
        cspkTimes_missed = [];
        exclude = [];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
    elseif strcmp(files{f},'C:\olivia\data\ephys\N087\N087_180306_t04_2000.mat')
        % 1 - CSpk triggered on falling phase
        % 2 - CSpk triggered on rising phase
        % 3 - SS
        % 4 - spikelet/garbage
        % 5 - SS
        % 6 - CSpk triggered on Ca2+ component
        % 7 - SS followed by CSpk

        ssIdx = nw_17.codes(:,1)==3 | nw_17.codes(:,1)==5 | nw_17.codes(:,1)==7;
        cspkIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==2 | nw_17.codes(:,1)==6;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==7;
        cspkTimes_missed = [];
        exclude = [];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
    elseif strcmp(files{f},'C:\olivia\data\ephys\N087\N087_180306_t05_2150.mat')
        % 1 - SS
        % 2 - CSpk triggered on rising phase
        % 3 - CSpk triggered on falling phase
        % 4 - CSpk triggered on Ca2+ component
        % 5 - spikelet/garbage
        % 6 - SS followed by CSpk
        % 7 - CSpk triggered on something weird
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==6;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==3 |...
            nw_17.codes(:,1)==4 | nw_17.codes(:,1)==7;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==6;
        cspkTimes_missed = [82.257; 91.231; 144.775; 163.571; 185.858;...
            199.229; 204.947; 211.217; 212.477];
        exclude = [390,max(nw_17.times)];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
    elseif strcmp(files{f},'C:\olivia\data\ephys\N087\N087_180306_t06_2000.mat')
        % 1 - SS
        % 2 - CSpk triggered on rising phase
        % 3 - weird CSpk
        % 4 - SS followed by CSpk
        % 5 - CSpk triggered on falling phase
        % 6 - CSpk triggered on Ca2+ component
        % 7 - spikelet/garbage
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==4;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==3 ...
            | nw_17.codes(:,1)==5 | nw_17.codes(:,1)==6;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==4;
        cspkTimes_missed = [];
        exclude = [150,max(nw_17.times)];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
        
    elseif strcmp(files{f},'C:\olivia\data\ephys\N087\N087_180306_t06_2075.mat')
        % 1 - SS
        % 2 - CSpk triggered on rising phase
        % 3 - CSpk triggered on falling phase
        % 4 - SS
        % 5 - SS folowed by CSpk
        % 6 - garbage
        % 7 - CSpk triggered on Ca2+ transient
        
        ssIdx = nw_17.codes(:,1)==1 | nw_17.codes(:,1)==4 ...
            | nw_17.codes(:,1)==5;
        cspkIdx = nw_17.codes(:,1)==2 | nw_17.codes(:,1)==3 ...
            | nw_17.codes(:,1)==7;
        cspkIdx_butAdd800 = nw_17.codes(:,1)==5;
        cspkTimes_missed = [3.023; 6.444];
        exclude = [];
        
        ssIdx_2 = [];
        cspkIdx_2 = [];
        cspkIdx_butAdd800_2 = [];
        cspkTimes_missed_2 = [];
       
        % ADD IN ANALYSIS OF RESPONSE TO PUFF
    end
    
    
    %% get SS and CSpk firing rates, ISIs, CV, CV2, etc.
    
    if isempty(exclude)==1 && isempty(ssIdx_2)==1
        % handles normal case when all the wavemarks were in one channel
        % and there were no messed up bits of the recording to exclude
        
        ssTimes = nw_17.times(ssIdx); % SS timestamps in seconds
        ssCount = sum(ssIdx);
        recDur = nw_17.times(end)-nw_17.times(1); % measure recording duration based on event times
        ssFR = ssCount/recDur;
        ssISI = diff(ssTimes);
        ssCV = std(ssISI)/mean(ssISI);
        ssCV2 = cv2(ssTimes);
        
        cspkTimes = [nw_17.times(cspkIdx); ...
            nw_17.times(cspkIdx_butAdd800)+0.8;...
            cspkTimes_missed];
        cspkTimes = sort(cspkTimes);
        cspkCount = length(cspkTimes);
        cspkFR = cspkCount/recDur;
        cspkISI = diff(cspkTimes);
        cspkCV = std(cspkISI)/mean(cspkISI);
        cspkCV2 = cv2(cspkTimes);
        
    elseif isempty(exclude)==0 && isempty(ssIdx_2)==1
        % handles case where there was some messed up bit of the recording
        % that has to be excluded but there is no second channel of
        % wavemark data
        
        
        ssTimes = nw_17.times(ssIdx); % SS timestamps in seconds
        cspkTimes = [nw_17.times(cspkIdx); ...
            nw_17.times(cspkIdx_butAdd800)+0.8;...
            cspkTimes_missed];
        cspkTimes = sort(cspkTimes);
        recDur = nw_17.times(end)-nw_17.times(1); % measure recording duration based on event times

        % turn all the valuse that should be excluded into NaNs
        % decrease recDur accordingly
        [r c] = size(exclude);
        for i = 1:r
            ssTimes(ssTimes>=exclude(i,1) & ssTimes<=exclude(i,2),1)=NaN;
            cspkTimes(cspkTimes>=exclude(i,1) & cspkTimes<=exclude(i,2),1)=NaN;
            recDur = recDur - (exclude(i,2)-exclude(i,1));
        end
        
        ssCount = sum(~isnan(ssTimes));
        ssFR = ssCount/recDur;
        ssISI = diff(ssTimes);
        ssCV = nanstd(ssISI)/nanmean(ssISI);
        ssCV2 = cv2(ssTimes);
        
        cspkCount = sum(~isnan(cspkTimes));
        cspkFR = cspkCount/recDur;
        cspkISI = diff(cspkTimes);
        cspkCV = nanstd(cspkISI)/nanmean(cspkISI);
        cspkCV2 = cv2(cspkTimes);
        
    elseif isempty(exclude)==1 && isempty(ssIdx_2)==0
        % handles case where there was a second wavemark channel but
        % there is no messed up bit of the recording to exclude
        
        ssTimes = nw_17.times(ssIdx); % SS timestamps in seconds
        ssTimes_2 = nw_17_2.times(ssIdx_2);
        
        ssCount = sum(ssIdx)+sum(ssIdx_2);
        
        recDur = (nw_17.times(end)-nw_17.times(1))+(nw_17_2.times(end)-nw_17_2.times(1)); % measure recording duration based on event times
        
        ssFR = ssCount/recDur;
        
        ssISI = [diff(ssTimes);NaN;diff(ssTimes_2)];
        ssCV = nanstd(ssISI)/nanmean(ssISI);
        ssCV2 = cv2([ssTimes;NaN;ssTimes_2]);
        
        cspkTimes = [nw_17.times(cspkIdx); ...
            nw_17.times(cspkIdx_butAdd800)+0.8;...
            cspkTimes_missed];
        cspkTimes_2 = [nw_17_2.times(cspkIdx_2); ...
            nw_17_2.times(cspkIdx_butAdd800_2)+0.8;...
            cspkTimes_missed_2];
        cspkTimes = sort(cspkTimes);
        cspkTimes_2 = sort(cspkTimes_2);
        cspkCount = length(cspkTimes)+length(cspkTimes_2);
        cspkFR = cspkCount/recDur;
        cspkISI = [diff(cspkTimes);NaN;diff(cspkTimes_2)];
        cspkCV = nanstd(cspkISI)/nanmean(cspkISI);
        cspkCV2 = cv2([cspkTimes;NaN;cspkTimes_2]);
        
    end
    
    
    %% put values in big array that will persist through the next iteration
    data.ssFR(f,1) = ssFR;
    data.cspkFR(f,1) = cspkFR;
    data.ssCV(f,1) = ssCV;
    data.ssCV2{f,1} = ssCV2;
    data.cspkCV(f,1) = cspkCV;
    data.cspkCV2{f,1} = cspkCV2;
    data.recDur(f,1) = recDur;
    
    clearvars -except files f data
        
end



%% lazy plotting, not flexible enough to accomodate any changes to file structure after 4/16
% rows 1-6 are N085 (WT)
% rows 7-111 are N087 (mutant)

quantileBoxScatter(data.ssFR(1:6), data.ssFR(7:11), 'WT', 'MUT', 'SS FR', 'En1 MECP2 KO Project (OK Only)')
quantileBoxScatter(data.cspkFR(1:6), data.cspkFR(7:11), 'WT', 'MUT', 'CSPK FR', 'En1 MECP2 KO Project (OK Only)')
quantileBoxScatter(data.ssCV(1:6), data.ssCV(7:11), 'WT', 'MUT', 'SS CV', 'En1 MECP2 KO Project (OK Only)')
quantileBoxScatter(data.cspkCV(1:6), data.cspkCV(7:11), 'WT', 'MUT', 'CSPK CV', 'En1 MECP2 KO Project (OK Only)')

controldata = [];
mutantdata = [];
for i = 1:11
    if i<7
        controldata = [controldata;data.cspkCV2{i,1}.cv2_avg];
    else
        mutantdata = [mutantdata;data.cspkCV2{i,1}.cv2_avg];
    end
end
quantileBoxScatter(controldata, mutantdata, 'WT', 'MUT', 'CSPK CV2', 'En1 MECP2 KO Project (OK Only)')

controldata = [];
mutantdata = [];
for i = 1:11
    if i<7
        controldata = [controldata;data.ssCV2{i,1}.cv2_avg];
    else
        mutantdata = [mutantdata;data.ssCV2{i,1}.cv2_avg];
    end
end
quantileBoxScatter(controldata, mutantdata, 'WT', 'MUT', 'SSCV2', 'En1 MECP2 KO Project (OK Only)')


%% adding data from the MECP2 spreadsheet
% data from 180418 update to spreadsheet, includes 4 mice
% did not account for when shogo said CSpk isolation was bad
ssFR_WT = [79.16; 58.79; 100.58; 70.12; 67.61; 98.68; 143.65; 81.94; ...
    56.73; 89.69; 97.82; 43.38; 96.02; 119.35;...
    80.12];
ssFR_MUT = [83.35; 81.14; 71.47; 102.27; 81.2; 66.12; 129.1; 80.09; ...
    86.09; 105.54; 118.47; 66.34; 139.01; 105.54;...
    87.98; 105.85; 83.57; 110.53; 130.08];


ssCV2_WT = [0.4; 0.41; 0.32; 0.33; 0.34; 0.28; 0.29; 0.42;...
    0.52; 0.35; 0.37; 0.56; 0.31; 0.31;...
    0.27];
ssCV2_MUT = [0.49; 0.41; 0.49; 0.49; 0.38; 0.42; 0.32; 0.36; 0.52;...
    0.38; 0.3; 0.4; 0.33; 0.38;...
    0.35; 0.30; 0.57; 0.41; 0.29];

cspkFR_WT = [0.99; 1.96; 0.68; 1.22; 1.11; 1.15; 1.46; 0.92;...
    1.33; 1.50; 1.17; 1.39; 1.26; 1.03;...
    1.64];
cspkFR_MUT = [1.42; 0.77; 1.1; 1.48; 1.28; 1.34; 1.62; 1.06; 1.04; ...
    1.06; 1.37; 1.18; 1.52; 1.05;...
    1.16; 1.48; 1.55; 1.35];

%% plotting
% median and first quartile and scatter points
colordef white
quantileBoxScatter(ssFR_WT, ssFR_MUT, 'WT', 'MUT', 'SS FR', 'En1 MECP2 KO Project, WT n=15, MUT n=19, ranksum p=0.16')
quantileBoxScatter(ssCV2_WT, ssCV2_MUT, 'WT', 'MUT', 'SS CV2', 'En1 MECP2 KO Project, WT n=15, MUT n=19, ranksum p=0.18')
quantileBoxScatter(cspkFR_WT, cspkFR_MUT, 'WT', 'MUT', 'CSPK FR', 'En1 MECP2 KO Project, WT n=15, MUT n=18, ranksum p=0.68')

%% significance testing
ranksum(ssFR_WT, ssFR_MUT)
ranksum(ssCV2_WT, ssCV2_MUT)
ranksum(cspkFR_WT, cspkFR_MUT)

