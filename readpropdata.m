function [probdata] = readpropdata(filename)
%% Import prop data from text file.

%% Initialize variables.
% filename = 'C:\Users\egegs\OneDrive - Old Dominion University\Thesis\Findings\Thesis Code\NewCode\apcff_4.2x4_0618rd_8043.txt';
startRow = 2;

%% Format for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%8f%10f%10f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
% dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
dataArray = importdata(filename);
%% Close the text file.
fclose(fileID);

%% Create output variable
% apcff4 = table(dataArray{1:end-1}, 'VariableNames', {'J','CT','CP','eta'});
% probdata = table2array(apcff4);
probdata = dataArray.data;
%% Clear temporary variables
clearvars filename startRow formatSpec fileID dataArray ans;