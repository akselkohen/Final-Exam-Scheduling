% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [sdeScore,sdeSchedule]=studentsDoneEarlyScore(schedule,whichExams,sdeRampWeight)

% unpack student data
numStudents=size(whichExams,1);
totalNumExams=size(whichExams,2);

% Find out when each student can leave; format like a schedule
% create an array with exams in the schedule order
scheduleOrder=zeros(1,totalNumExams -2);
n=1;
for j=1:7
    for i=1:3
        exam=schedule(i,j);
        if exam ~= 0
            scheduleOrder(1,n)=exam;
            n=n+1;
        end
    end
end

for j=1:7
    for i=4:6
        exam=schedule(i,j);
        if exam ~= 0
            scheduleOrder(1,n)=exam;
            n=n+1;
        end
    end
end
% reorder whichExams accordingly; add helpful headers


whichExamsOrdered=zeros(1+numStudents,totalNumExams);
for i=1:totalNumExams-2
    exam_i=scheduleOrder(i);
    whichExamsOrdered(1,i)=exam_i;
    whichExamsOrdered(2:end,i)=whichExams(:,exam_i);
end

% find each students last exam; record the number
lastExam=zeros(numStudents,1);
for i=1:numStudents
    lastCol=sum(find(whichExamsOrdered(i+1,:),1,'last'));
    if lastCol ==0
        lastExam(i,1)=0;
    else
        lastExam(i,1)=whichExamsOrdered(1,lastCol);
    end
end
% populate a schedule with those numbers
% calculate a score 
sdeScore=0;
sdeSchedule=zeros(6,7);
for i=1:6
    for j=1:7
        if schedule(i,j) ~= 0
            weekDay=(floor(i/4)*7)+j;
            curWeight=sdeRampWeight*weekDay;
            sdeSchedule(i,j)=sum(lastExam(:,1)==schedule(i,j));
            sdeScore= sdeScore + sdeSchedule(i,j)*curWeight;
        end
    end
end

end