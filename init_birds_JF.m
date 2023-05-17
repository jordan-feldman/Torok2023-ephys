%% returns paths to the data in paths structure and birds structure contains bird information
%  birds{:, 1} = name 
%  birds{:, 2} = path index
%  birds{:, 3} = first or second bird in recording
%  birds{:, 4} = date
%  birds{:, 5} = number of birds in recording

function [paths, birds] = init_birds_JF()
%base_dir = '/Volumes/Jordan_Lois/';
base_dir = '/Volumes/LAB_DR2/';
paths{1} = [base_dir 'Control/2021-09-02_21-38-17_Or295_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{2} = [base_dir 'Control/2021-09-11_21-32-07_Or251_PK31_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{3} = [base_dir 'Control_day5_PK31_swr_sleep/2021-09-15_21-36-21_Or295_PK31_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{4} = [base_dir 'Experimental/4_days_post/2021-05-04_22-15-26_Or296_B138_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{5} = [base_dir 'Experimental/2021-05-01_21-37-31_Or296_overnight_only1/Record Node 101/experiment1/recording1/structure.oebin'];
paths{6} = [base_dir 'Experimental/2021-05-02_22-19-03_Or296_B138_overnight/Record Node 101/experiment1/recording1/structure.oebin'];

base_dir = '/Volumes/Shelyn_2/';
paths{7} = [base_dir 'Jordan_chronic/Control/2021-09-30_21-34-30_Or295_PK31_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{8} = [base_dir 'Jordan_chronic/Control/2021-10-18_21-35-45_Or295_PK31_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{9} = [base_dir 'Jordan_chronic/Control/2021-11-10_21-27-47_Or295_PK31_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{10} = [base_dir 'Jordan_chronic/Control/2021-11-29_21-22-52_Or295_PK31_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{11} = [base_dir 'Jordan_chronic/DLX/2021-05-19_21-32-00_Or296_B138_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{12} = [base_dir 'Jordan_chronic/DLX/2021-06-10_21-22-54_Or296_B138_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{13} = [base_dir 'Jordan_chronic/DLX/2021-06-28_21-29-49_Or296_B138_overnight/Record Node 101/experiment1/recording1/structure.oebin'];
paths{14} = [base_dir 'Jordan_chronic/DLX/2021-07-20_17-56-24_Or296_B138_overnight_6pm/Record Node 101/experiment1/recording1/structure.oebin'];

%first colum is bird name
birds{1, 1} = 'OR295';
birds{2, 1} = 'OR251';
birds{3, 1} = 'PK31';
birds{4, 1} = 'OR295';
birds{5, 1} = 'PK31';
birds{6, 1} = 'OR296';
birds{7, 1} = 'B138';
birds{8, 1} = 'OR296';
birds{9, 1} = 'OR296';
birds{10, 1} = 'B138';

birds{11, 1} = 'OR295';
birds{12, 1} = 'PK31';
birds{13, 1} = 'OR295';
birds{14, 1} = 'PK31';
birds{15, 1} = 'OR295';
birds{16, 1} = 'PK31';
birds{17, 1} = 'OR295';
birds{18, 1} = 'PK31';
birds{19, 1} = 'OR296';
birds{20, 1} = 'B138';
birds{21, 1} = 'OR296';
birds{22, 1} = 'B138';
birds{23, 1} = 'OR296';
birds{24, 1} = 'B138';
birds{25, 1} = 'OR296';
birds{26, 1} = 'B138';

%second column is index of path to data
birds{1, 2} = 1;
birds{2, 2} = 2;
birds{3, 2} = 2;
birds{4, 2} = 3;
birds{5, 2} = 3;
birds{6, 2} = 4;
birds{7, 2} = 4;
birds{8, 2} = 5;
birds{9, 2} = 6;
birds{10, 2} = 6;

birds{11, 2} = 7;
birds{12, 2} = 7;
birds{13, 2} = 8;
birds{14, 2} = 8;
birds{15, 2} = 9;
birds{16, 2} = 9;
birds{17, 2} = 10;
birds{18, 2} = 10;
birds{19, 2} = 11;
birds{20, 2} = 11;
birds{21, 2} = 12;
birds{22, 2} = 12;
birds{23, 2} = 13;
birds{24, 2} = 13;
birds{25, 2} = 14;
birds{26, 2} = 14;

%third column is whether it is first of second bird
birds{1, 3} = 1;
birds{2, 3} = 1;
birds{3, 3} = 2;
birds{4, 3} = 1;
birds{5, 3} = 2;
birds{6, 3} = 1;
birds{7, 3} = 2;
birds{8, 3} = 1;
birds{9, 3} = 1;
birds{10, 3} = 2;

birds{11, 3} = 1;
birds{12, 3} = 2;
birds{13, 3} = 1;
birds{14, 3} = 2;
birds{15, 3} = 1;
birds{16, 3} = 2;
birds{17, 3} = 1;
birds{18, 3} = 2;
birds{19, 3} = 1;
birds{20, 3} = 2;
birds{21, 3} = 1;
birds{22, 3} = 2;
birds{23, 3} = 1;
birds{24, 3} = 2;
birds{25, 3} = 1;
birds{26, 3} = 2;

%fourth column is the date
birds{1, 4} = '09-02';
birds{2, 4} = '09-11';
birds{3, 4} = '09-11';
birds{4, 4} = '09-15';
birds{5, 4} = '09-15';
birds{6, 4} = '05-04';
birds{7, 4} = '05-04';
birds{8, 4} = '05-01';
birds{9, 4} = '05-02';
birds{10, 4} = '05-02';

birds{11, 4} = '09-30';
birds{12, 4} = '09-30';
birds{13, 4} = '10-18';
birds{14, 4} = '10-18';
birds{15, 4} = '11-10';
birds{16, 4} = '11-10';
birds{17, 4} = '11-29';
birds{18, 4} = '11-29';
birds{19, 4} = '05-19';
birds{20, 4} = '05-19';
birds{21, 4} = '06-10';
birds{22, 4} = '06-10';
birds{23, 4} = '06-28';
birds{24, 4} = '06-28';
birds{25, 4} = '07-21';
birds{26, 4} = '07-21';

%fifth column is number of birds on file
birds{1, 5} = 1;
birds{2, 5} = 2;
birds{3, 5} = 2;
birds{4, 5} = 2;
birds{5, 5} = 2;
birds{6, 5} = 2;
birds{7, 5} = 2;
birds{8, 5} = 1;
birds{9, 5} = 2;
birds{10, 5} = 2;

birds{11, 5} = 2;
birds{12, 5} = 2;
birds{13, 5} = 2;
birds{14, 5} = 2;
birds{15, 5} = 2;
birds{16, 5} = 2;
birds{17, 5} = 2;
birds{18, 5} = 2;
birds{19, 5} = 2;
birds{20, 5} = 2;
birds{21, 5} = 2;
birds{22, 5} = 2;
birds{23, 5} = 2;
birds{24, 5} = 2;
birds{25, 5} = 2;
birds{26, 5} = 2;
end