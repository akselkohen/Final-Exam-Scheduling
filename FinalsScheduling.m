% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

%% STUDENT DATA
% Data must be stored in excel file
% Format: AnonID | YearOf Student | URM | Major1 | Major2 | CourseTimes 1,...n
fileName='With Common Exams - Fall 2016 Week 2.xlsx';
%fileName='No Common Exams - Fall 2017 Week 2.xlsx';
[numericData,textData,~]=xlsread(fileName);

% This gives names or 'keys' to datasets that we'll use as function
% arguments, so we don't have to type so much
% You need MATLAB 2016b or later for containers.Map
studentData = containers.Map;

% Store demographic information
demoTypes=['anonID','studentYr','urm','major1','major2'];
studentData('demoTypes')=demoTypes;

anonID=numericData(2:end,1);          
studentData('anonID')=anonID;
studentYr=numericData(2:end,2);       
studentData('studentYr')=studentYr;
urm=numericData(2:end,3);             
studentData('urm')=urm;
major1=textData(2:end,4);             
studentData('major1')=major1;
major2=textData(2:end,5);             
studentData('major2')=major2;

% Store exam information
whichExams=numericData(2:end,6:end);
studentData('whichExams')=whichExams;
numStudents=size(whichExams,1);
totalNumExams=size(whichExams,2);

% Storing naming information
examNames=["MWF 8am","MWF 9am","MWF 10am","MWF 11AM", ...
            "MWF noon","MWF 1:30pm","MWF 3pm","MWF 4:30pm", ...
            "TTh 9am","TTh 10:30am","TTh noon","TTh 1:30pm", ...
            "TTh 3pm","TTh 4:30pm","MATH common","LANG common", ...
            "M 6pm","T 6pm","W 6pm","Th 6pm", ...
            "BIOLOGY","CS 220/120"];
studentData('examNames')=examNames;
numExamNames=length(examNames);
if numExamNames ~= totalNumExams
    error('You gave %d exam names, but there are %d exams!',numExamNames,totalNumExams)
end

% Build Collision Matrix and Tensor
% Matrix and tensor to count total number of students taking each pair or trio of exams
% There is an extra row, column, width for empty placeholders
[collisionMatrix, collisionTensor]=studentCollisions(whichExams);
% Populate studentData
studentData('collisionMatrix') = collisionMatrix;
studentData('collisionTensor') = collisionTensor;


%% SCHEDULE TEMPLATE DATA
% Place ones where exams may be scheduled,
% and zeros where exams cannot be scheduled
templateData=containers.Map;


templateData('constrExams')=constrExams;
% Exams that should occur in the first x days
earlyExams=[15];
templateData('earlyExams')=earlyExams;

fullTemplate=...
[0  0  1  1  1  1  0 ; %week 1
 0  0  1  1  1  1  0 ;
 0  1  1  1  1  0  0 ;
 ... 
 0  1  1  1  1  0  0 ; %week 2
 0  1  1  1  0  0  0 ;
 0  1  1  1  0  0  0 ];
%S  M  T  W  H  F  S
templateData('fullTemplate')=fullTemplate;

% Check user input to ensure correct number of slots
totalNumSlots=sum(sum(fullTemplate));
if totalNumSlots ~= totalNumExams
    error(['The number of exams in the student data',...
        'and the number of slots in the template do not match.\n', ...
        'Number of exams: %d\n'...
        'Number of slots: %d'], totalNumExams, totalNumSlots);
end

% Allow user to constrain/schedule some exams into slots manually
numConstrExams=length(constrExams);
constrTemplate=...
[0  0  0  0  0  0  0 ; %week 1
 0  0  0  0  0  0  0 ;
 0  17 18 19 20 0  0 ;
 ... 
 0  0  0  0  0  0  0 ; %week 2
 0  0  0  0  0  0  0 ;
 0  0  0  0  0  0  0 ];
%S  M  T  W  H  F  S
templateData('constrTemplate')=constrTemplate;

% Identify exams that will be scheduled manually from constrained template
constrExams=[];
for i=[1 4]
    for j=1:7 
     if sum(constrTemplate(i:i+2,j)>0)
        day=constrTemplate(i:i+2,j);
        ex_index = day~=0;
        constrExams=[constrExams day(ex_index)'];
           
     end
    end
end

 %based on ordering of time slots. M=17, T=18, W=19, Th=20
templateData('constrExams')=constrExams;

% add error checking in case const. template
% -doesn't fit fullTemplate
% -repeats any exams, excludes constrExams

%% Create a Template for Exams to be Scheduled
% workingTemplate=fullTemplate;
% for i=1:6
%     for j=1:7
%         if constrTemplate(i,j)>0
%             workingTemplate(i,j)=0;
%         end
%     end
% end
% templateData('workingTemplate')=workingTemplate;

%% SCORING OPTIONS
scoringOptions=containers.Map;

% COLLISION SCORING
% Define the types of collisions to be scored
% Collisions occur when students have exams scheduled in nearby slots
% twoB2b: two exams on the same day in adjacent slots
% twoWb: two exams on the same day with one slot between
% twoOvn: two exams on adajcent days; last slot of Day1 and first slot Day2
% threeb2b: three exams on the same day in adjacent slots
% threeOvn: three exams on adjacent days; last slots of Day1 and first of Day2

scoringOptions('collisionTypes')=      ["twoB2b", "twoWb", "twoOvn", "threeB2b", "threeOvn"];
% Choose which scores to print out (see above)
scoringOptions('whichCollisionScores')=[   1    ,    1   ,    1    ,     1     ,      1    ];
% Assign weights to each score
scoringOptions('collisionWeights')=    [   1    ,   0.5  ,  0.25   ,     5     ,      0.75    ];

% OTHER SCORING
scoringOptions('otherTypes')=      ["studentsDoneEarly","earlyExamsMet", "friEvePunished"];
scoringOptions('whichOtherScores')=[       1           ,        1     ,      0 ];
scoringOptions('otherWeights')=    [       5        ,       10000     ,     10 ];

%% OPTION: MERGE EXAMS AND UPDATE INPUT DATA
% [studentData,templateData]=mergeExams(5,6,studentData,templateData);
% tic;
% [mergeInfoList] = mergeTree(studentData,templateData);
% toc
% 
% allowableThreeB2b=10;
% sampleSize=100;
% giveSummary=0;
% m=mergeInfoList(4);
% studentData=m.studentData;
% templateData=m.templateData;
% schedule= genSchedule_goodDaysMethod(studentData,templateData,scoringOptions,allowableThreeB2b,sampleSize,giveSummary);
% scheduleAnalyizer(schedule,studentData,templateData,scoringOptions)

%% GEN SCHEDULE: GOOD DAYS METHOD
%Specify the number of threeB2b collisions allowed per day
allowableThreeB2b=0;
sampleSize=10000;
giveSummary=1;
crucialtriples=[];
crucialpairs=[ ];
forbiddenpairs=[17 18; 17 19; 17 20; 18 19; 18 20;19 20]; % specifically here, these pairs will be fixed and thus need different days
maxthreetotal=0; %number of threeB2B collisions allowed in the entire schedule
%typesdisallowed=[17 2; 17 3; 19 1; 19 2; 18 1; 18 2; 20 1; 20 2;3 1;3 2]; % see line above
% ^gooddaysmethod will automatically calculate typesdisallowed
schedule= genSchedule_goodDaysMethod2(studentData,templateData,scoringOptions,allowableThreeB2b,forbiddenpairs, crucialtriples,crucialpairs,maxthreetotal, sampleSize,giveSummary);
scheduleAnalyizer(schedule,studentData,templateData,scoringOptions)

%% GEN SCHEDULE: MONTE CARLO METHOD
%schedule2= genSchedule_monteCarloMethod (studentData,templateData,scoringOptions,sampleSize,giveSummary)
%scheduleAnalyizer(schedule12,studentData,templateData,scoringOptions)

