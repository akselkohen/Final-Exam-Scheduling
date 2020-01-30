% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [mergedStudentData, mergedTemplateData] = mergeExams(exami,examj,studentData,templateData)
%Given two exams, combines them into one exam and generates new studentData
%and templateData
%change
constrExams=templateData('constrExams');
% if both are constr, throw error
% if ismember(exami,constrExams) && ismember(examj,constrExams)
%     error('Exam %d and exam %d are both constrained exams, so they cannot be merged',exami,examj);
% end

% unpack old data
whichExams=studentData('whichExams');
numStudents=size(whichExams,1);
totalNumExams=size(whichExams,2);
examNames=studentData('examNames');
constrExams=templateData('constrExams');
numConstrExams=length(constrExams);
constrTemplate=templateData('constrTemplate');
earlyExams=templateData('earlyExams');
collisionMatrix=studentData('collisionMatrix');
collisionTensor=studentData('collisionTensor');
fullTemplate=templateData('fullTemplate');
workingTemplate=templateData('workingTemplate');

% create containers for new merged (m) data
mergedStudentData=containers.Map;
mergedTemplateData=containers.Map;

% Keep track of previous slot numbers. 
exam1=min(exami,examj);
exam2=max(exami,examj);

% Merge whichExams data into earliest exam.
% Update examNames as everything will be shifted
mWhichExams=zeros(numStudents,totalNumExams-1);
mExamNames=strings(1,totalNumExams-1);

mWhichExams(:,1:(exam1-1))=whichExams(:,1:(exam1-1));
mExamNames(1,1:(exam1-1))=examNames(1,1:(exam1-1));
mWhichExams(:,exam1)=whichExams(:,exam1)+whichExams(:,exam2);
mExamNames(1,exam1)=strcat(examNames(1,exam1),' & ',examNames(1,exam2));
mWhichExams(:,(exam1+1):(exam2-1))=whichExams(:,(exam1+1):(exam2-1));
mExamNames(1,(exam1+1):(exam2-1))=examNames(1,(exam1+1):(exam2-1));
mWhichExams(:,exam2:end)=whichExams(:,(exam2+1):end);
mExamNames(:,exam2:end)=examNames(1,(exam2+1):end);

%%
% updating whichExams
mWhichExams = whichExams;

mWhichExams(:,exam1)=whichExams(:,exam1)+whichExams(:,exam2);
mWhichExams(:,exam2)=zeros(numStudents,1);

for i = exam2:totalNumExams-1
    mWhichExams(:,i)=mWhichExams(:,i+1);
end

mWhichExams(:,totalNumExams)=zeros(numStudents,1);

% updating examNames

mExamNames = examNames;

mExamNames(:,exam1)=strcat(examNames(1,exam1)," & ",examNames(1,exam2));
mExamNames(:,exam2)="";

for i = exam2:totalNumExams-1
    mExamNames(:,i)=mExamNames(:,i+1);
end

mExamNames(:,totalNumExams)="";

%%

mergedStudentData('whichExams')=mWhichExams;
mergedStudentData('examNames')=mExamNames;

% Update constrExams and constrTemplate with merged number
mConstrExams=constrExams;
mConstrTemplate=constrTemplate;
if ismember(exam2,constrExams)
    loc=find(constrExams==exam2);
    mConstrExams(loc)=exam1;
    [loci,locj]=find(constrTemplate==exam2);
    mConstrTemplate(loci,locj)=exam1;
end

mergedTemplateData('constrExams')=mConstrExams;
mergedTemplateData('constrTemplate')=mConstrTemplate;
    
% Update early exams with merged number
if ismember(exam1,earlyExams) && ismember(exam2,earlyExams)
    mEarlyExams=setdiff(earlyExams,exam2);
elseif ismember(exam2,earlyExams)
    loc=find(earlyExams==exam2);
    earlyExams(loc)=exam1;
    mEarlyExams=earlyExams;
else 
    mEarlyExams=earlyExams;
end

mergedTemplateData('earlyExams')=mEarlyExams;

% Update collisionMatrix and collisionTensor
[mCollisionMatrix,mCollisionTensor]=studentCollisions(mWhichExams);
mergedStudentData('collisionMatrix')=mCollisionMatrix;
mergedStudentData('collisionTensor')=mCollisionTensor;

% update fullTemplate and workingTemplate
mWorkingTemplate=workingTemplate;

flag=0;
for i=14:-1:1
    for j=3:-1:1
        week=floor((i-1)/7);
        row=(week*3)+j;
        col=i-(week*7);
        if fullTemplate(row,col)==1
            mWorkingTemplate(row,col)=0;
            flag=1;
        end
        if flag==1
            break;
        end
    end
    if flag==1
        break;
    end
end

mFullTemplate=mWorkingTemplate+mConstrTemplate;
mFullTemplate=mFullTemplate./mFullTemplate;

mergedTemplateData('workingTemplate')=mWorkingTemplate;
mergedTemplateData('fullTemplate')=mFullTemplate;

mergedTemplateData('workingTemplate')=templateData('workingTemplate');
mergedTemplateData('fullTemplate')=templateData('fullTemplate');

%copy everything else that's unchanged
mergedStudentData('demoTypes')=studentData('demoTypes');
mergedStudentData('anonID')=studentData('anonID');
mergedStudentData('studentYr')=studentData('studentYr');            
mergedStudentData('urm')=studentData('urm');          
mergedStudentData('major1')=studentData('major1');            
mergedStudentData('major2')=studentData('major2');

end
