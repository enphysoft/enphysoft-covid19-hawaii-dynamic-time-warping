%+TITLE: Dynamic Time Wraping for Time Series Analysis of the State of Hawaii
%+File: HawaiiCOVID19.m
%+Date: Sat Dec  5 18:28:28 HST 2020
%+Author: Myles Gota, mgota@hawaii.edu 

% ACTIVATE ONE OF THE FOLLOWING PARAMETERS:
    parameter = 'Honolulu.Cases';
    %parameter = 'Hawaii.Cases';
    %parameter = 'Maui.Cases';
    %parameter = 'Kauai.Cases';
    %parameter = 'Honolulu.TripDistance.Cases';
    %parameter = 'Hawaii.TripDistance.Cases';
    %parameter = 'Maui.TripDistance.Cases';
    %parameter = 'Kauai.TripDistance.Cases';

% CHOOSE INITIAL START DAY (1 = JANUARY 1, 2020):
    iniRow = 95;

% SAVE FIGURES TO FOLDER?
    %saveFig = 'Yes';
    saveFig = 'No';

% Format to have more digits after the decimal point    
format long; 

% Create table from Excel data file based on chosen parameter
dataTable = readtable('HawaiiDataCOVID19.xlsx','Sheet',parameter,...
                      'Range','B1','VariableNamingRule','preserve');        
	
% Set variable names for figure file names and annotation
str = dataTable.Properties.VariableNames;	

% Remove variable name of first element
str(1) = [];                                                                

% Convert table to initial data array
mydataIni = table2array(dataTable);                                         

% Return the number of rows and columns of initial data array separately
[numRowsIni,numColsIni] = size(mydataIni);                                  

% Create data array from initial data array based on chosen data start day
mydata = mydataIni(iniRow:numRowsIni,2:numColsIni);                         

% Return the number of rows and columns of data array separately
[numRows,numCols] = size(mydata);                                           

% Create and initialize array for positive normalized DTW Euclidean distances
posDTWdist(1:numCols-1) = 0;                                                

% Create and initialize array for negative normalized DTW Euclidean distances
negDTWdist(1:numCols-1) = 0;                                                

% Create initial reference vector using first column of data array
refvecIni = mydata(:,1);                                                    








% Loop for amount of test vectors
for j = 1:numCols-1                                                         
    refvec = refvecIni;		% Initialize reference vector to initial reference vector

    testvec = mydata(:,j+1);	% Create test vector using next column of data array

    removePair = [];	% Create and initialize array 
			% for the row numbers of pairs that need to be removed

    % Loop for amount of rows of data array
    for k = 1:numRows 
	% Check if either reference or test vector has a missing value (NaN) at that row
        if (isnan(refvec(k)) == 1) | (isnan(testvec(k)) == 1)	

	    % Assign row number to next position in array for pairs that need to be removed
            removePair(end+1) = k;	
        end
    end

    % Remove value at row numbers of pairs that need to be removed from reference vector
    refvec(removePair)=[]; 
    % Remove value at row numbers of pairs that need to be removed from test vector
    testvec(removePair)=[]; 
    % Number of pairs removed
    pairsRemoved = numel(removePair); 
    % Normalize reference vector
    refvec = normalize_vector(refvec); 
    % Normalize reference vector using number of data points
    refvec = refvec / real(numRows-pairsRemoved); 
    % Normalize test vector
    testvec = normalize_vector(testvec);                                    
    % Normalize test vector using number of data points
    testvec = testvec / real(numRows-pairsRemoved);                         
    % Calculate positive normalized DTW Euclidean distance from Dynamic Time Warping function
    posDTWdist(j) = dtw(testvec,refvec);                                    

    % Create figure of the original and aligned signals for positive normalized test vector
    f = figure; dtw(testvec,refvec);                                        
    
    if strcmp(saveFig,'Yes')		% Save figure if desired
        Name = cell2mat(str(j+1));	% Variable name of test vector
        saveas(f,sprintf('fig.%s.%03d.Pos.%s.png',parameter,iniRow,Name));  
		% Save figure with detailed file name
    end

    
    negDTWdist(j) = dtw(-testvec,refvec);	% Calculate negative normalized DTW Euclidean 
						% distance from Dynamic Time Warping function
    f = figure; dtw(-testvec,refvec);		% Create figure of the original and aligned 
						% signals for negative normalized test vector

    if strcmp(saveFig,'Yes')			% Save figure if desired
        saveas(f,sprintf('fig.%s.%03d.Neg.%s.png',parameter,iniRow,Name));  
		% Save figure with detailed file name
    end
end







% Create figure plot for normalized DTW Euclidean distances
f = figure; 

% Set array indices
jColIdx = 1:1:numCols-1; 

% Plot all positive normalized DTW Euclidean distances
plot(jColIdx,posDTWdist,"o-",'LineWidth',2); hold on;                       

% Plot all negative normalized DTW Euclidean distances
plot(jColIdx,negDTWdist,"^-",'LineWidth',2); hold on; 

% Set x-axis properties
set(gca,'xtick',1:1:numCols-1); 

% Set the x-axis limits to allow space for displaying annotation
xlim([0 numCols+7]); 

% Label the x-axis
xlabel("Array Indices"); 

% Set the y-axis limits
ylim([0.2 1.2]);

% Label the y-axis
ylabel("Normalized DTW Euclidean Distances"); 

% Displays the major grid lines
grid on; 

% Create legend
legend('Positive Normalized','Negative Normalized','Location','northwest'); 

% Set location and dimensions for annotation
dim = [.67 .30 .20 .55]; 

% Create text box annotation
annotation('textbox',dim,'String',str,'FitBoxToText','on');                 

% Create title
title(sprintf('DTW for %s from Day %03d',parameter,iniRow));                

% Save figure if desired
if strcmp(saveFig,'Yes')                                                    
    % Save figure with detailed file name
    saveas(f,sprintf('fig.%s.%03d.DTW.png',parameter,iniRow));              
end
% End program 
