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
fileName='With Common Exams - Fall 2017 Week 2(fix).xlsx';
%fileName='No Common Exams - Fall 2017 Week 2.xlsx';
[numericData,textData,~]=xlsread(fileName);

% This gives names or 'keys' to datasets that we'll use as function
% arguments, so we don't have to type so much
% You need MATLAB 2016b or later for containers.Map
studentData = containers.Map;

% Store demographic information
demoTypes=["anonID","studentYr","urm","major1","major2"];
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

% Exams that will be scheduled manually
constrExams=[17 18 19 20]; %based on ordering of time slots. M=17, T=18, W=19, Th=20
templateData('constrExams')=constrExams;
% Exams that should occur in the first x days
earlyExams=[15 16];
templateData('earlyExams')=earlyExams;

fullTemplate=...
[0  0  1  1  1  1  0 ; %week 1
 0  0  1  1  1  1  0 ;
 0  1  1  1  1  1  0 ;
 ... 
 0  1  1  1  0  0  0 ; %week 2
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
 0  0 0  0  0  0  0 ];
%S  M  T  W  H  F  S
templateData('constrTemplate')=constrTemplate;


%% MERGING STUFF
% add error checking in case const. template
% -doesn't fit fullTemplate
% -repeats any exams, excludes constrExams

%find the zeros in the collision Matrix
possMerge=[];
for i=1:totalNumExams
    for j=i+1:totalNumExams
        if collisionMatrix(i,j)==0
            possMerge=[possMerge ; [i j]];
        end
    end
end

numPossMerge=size(possMerge,1);
% all singular choices
possMerge

% all pairs of choices
numPossMergeTwos=nchoosek(numPossMerge,2);
vec=1:numPossMerge;
indexTwos=nchoosek(vec,2);
for i=1:numPossMergeTwos
    temp=[ possMerge(indexTwos(i,1),:), possMerge(indexTwos(i,2),:) ];
    uni=unique(temp);
    if length(uni)==4
        %store the sets
    elseif length(uni)==3 && collisionTensor(uni(1),uni(2),uni(3))==0
        %store the sets
    end
end

% all triples of choices
%possMergeThree
