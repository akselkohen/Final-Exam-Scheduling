% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [] = scheduleAnalyizer(schedule,studentData,templateData,scoringOptions)
whichExams=studentData('whichExams');
examNames=studentData('examNames');
collisionTypes=scoringOptions('collisionTypes');
numCollisionTypes=length(collisionTypes);
collisionWeights=scoringOptions('collisionWeights');

otherWeights=scoringOptions('otherWeights');
eemWeight=otherWeights(1,2);
sdeRampWeight=otherWeights(1,1);

studentYr=studentData('studentYr');
urm=studentData('urm');
major1=studentData('major1');
major2=studentData('major2');
numStudents=size(whichExams,1);
totalNumExams=size(whichExams,2);

earlyExams=templateData('earlyExams');

%% Output The Best Schedule, Formatted Nicely
disp('The Best Arranged Schedule was:');
printFormattedSchedule(schedule)

bestSched_named=strings(6,7);
for i=1:6
    for j=1:7
        exam=schedule(i,j);
        if exam ~=0
        bestSched_named(i,j)=examNames(exam);
        end
    end
end
printFormattedSchedule(bestSched_named)

% Overall score
score=scoreFunction(schedule,studentData,templateData,scoringOptions);
[collisionScore, collisionCounts, collisionCountsByStudent] = collisionScores(schedule,studentData,scoringOptions);
[eemScore, earlyExamsNotMet]= earlyExamsMetScore(schedule,earlyExams,eemWeight);
[sdeScore,sdeSchedule]=studentsDoneEarlyScore(schedule,whichExams,sdeRampWeight);
fprintf('The student collision score of the schedule was: %f\n',collisionScore);
fprintf('The overall score of the schedule was: %f\n',score);

%% More
% Counts of each collision type
disp('The schedule had: ');
for i=1:numCollisionTypes
    colCounts=collisionCounts(i);
    fprintf('%9s: %d\n',collisionTypes(i),collisionCounts(i));
end
disp(' ');

% Counts of collision type per student
disp('Collision types were distributed among students as follows:')
for i=1:numCollisionTypes
    colCounts=collisionCountsByStudent(:,i);
    fprintf('%9s: %.3f average/student, stdev= %.3f\n',collisionTypes(i),mean(colCounts),std(colCounts));
end
disp('See figure 2 for histograms of collision counts');
disp(' ')

figure(2)
for i=1:numCollisionTypes
subplot(1,5,i)
msg=collisionTypes(i)+' per student';
edges=-0.5:1:2.5;
histogram(collisionCountsByStudent(:,i),edges)
title(msg)
% -Add data labels-- its complicated because MATLAB
[counts,binIndx]=histcounts(collisionCountsByStudent(:,i),edges);
barstrings = num2str(counts');
len=length(binIndx);
x=zeros(1,len-1);
y=50*ones(1,len-1);
for j=1:(len-1)
    x(j)=(binIndx(j)+binIndx(j+1))/2;
end
text(x,y,barstrings,'horizontalalignment','center','verticalalignment','bottom')
end
saveas(gcf,'figure2.fig') % save plot to file
set(figure(2),'visible','off');

% Counts of collision type per class year; average and stdev
yearOfStudy=["(0) Special/Visiting","(1) Freshman","(2) Sophomore","(3) Junior","(4) Senior", ...
            "(5) Post-Bacc. Certificate","(6) Masters","(7) PhD","(8) Other"];
uniqueYr=unique(studentYr);
numYrs=length(uniqueYr);
yrsPresent=strings(1,numYrs);
colByYr=zeros(numCollisionTypes+1,numYrs);
studentsPerYr=zeros(1,numYrs);
for j=1:numYrs %for each student year
    isYr=(studentYr==uniqueYr(j));
    studentsPerYr(j)=sum(isYr);
    yrsPresent(1,j)=yearOfStudy(uniqueYr(j)+1);
    for i=1:numCollisionTypes %count each type of collision for that yr
        colByYr(i,j)=sum(isYr.*collisionCountsByStudent(:,i));
    end
    %-calculate the overall score for that year
    colByYr(numCollisionTypes+1,j)=dot(colByYr(1:numCollisionTypes,j),collisionWeights);
end
figure(3)
titles=[collisionTypes "Overall Score"];
c=categorical(yrsPresent);
for i=1:numCollisionTypes+1
    subplot(1,numCollisionTypes+1,i)
    bar(c,colByYr(i,:));
    
    labels = arrayfun(@(value) num2str(value,'%2.0f'),colByYr(i,:),'UniformOutput',false);
    text(c,colByYr(i,:),labels,"HorizontalAlignment","center","VerticalAlignment","bottom")
    maxNum = max(colByYr(i,:));
    %ylim([0 maxNum + 20]);
    ylim auto
    
    title(titles(i));
end %add data labels with num of each collision
saveas(gcf,'figure3.fig') % save plot to file
set(figure(3),'visible','off');

%disp('The student data had:')
for i=1:numYrs
    numStudentsInYr=studentsPerYr(i);
    avgScore=colByYr(numCollisionTypes+1,i)/numStudentsInYr;
    %fprintf('%4d %s students\n         with an avg. overall score of %.3f\n',numStudentsInYr,yrsPresent(i),avgScore);
end
disp('See figure 3 for details of collisions by year');
disp(' ');

% counts of collision type if urm vs not; average and stdev
uniqueURM=[0 1];
urmStatus=["Not URM","URM"];
numURMs=2;
colByURM=zeros(numCollisionTypes+1,numURMs);
colByURMavg=zeros(numCollisionTypes+1,numURMs);
studentsPerURM=zeros(1,numURMs);
for j=1:numURMs %for each student year
    isURM=(urm==uniqueURM(j));
    studentsPerURM(j)=sum(isURM);
    for i=1:numCollisionTypes %count each type of collision for that urm status
        colByURM(i,j)=sum(isURM.*collisionCountsByStudent(:,i));
        colByURMavg(i,j)=colByURM(i,j)/studentsPerURM(j);
    end
    %-calculate the overall score for that urm status
    colByURM(numCollisionTypes+1,j)=dot(colByURM(1:numCollisionTypes,j),collisionWeights);
    colByURMavg(numCollisionTypes+1,j)=dot(colByURMavg(1:numCollisionTypes,j),collisionWeights);
end
figure(4)
titles=[collisionTypes "Overall Score"];
c=categorical(urmStatus);
for i=1:numCollisionTypes+1
    subplot(2,numCollisionTypes+1,i)
    bar(c,colByURM(i,:));
    
    labels = arrayfun(@(value) num2str(value,'%2.0f'),colByURM(i,:),'UniformOutput',false);
    text(c,colByURM(i,:),labels,'HorizontalAlignment','center','VerticalAlignment','bottom')
    maxNum = max(colByURM(i,:));
    %ylim([0  maxNum + 50]);
    ylim auto 
    
    title([titles(i) 'total']);
    
    subplot(2,numCollisionTypes+1,i+numCollisionTypes+1)
    bar(c,colByURMavg(i,:));
    
    labels = arrayfun(@(value) num2str(value,'%2.3f'),colByURMavg(i,:),'UniformOutput',false);
    text(c,colByURMavg(i,:),labels,'HorizontalAlignment','center','VerticalAlignment','bottom')
    maxNum = max(colByURMavg(i,:));
   
    %ylim([0 maxNum+.02]);
    ylim auto
    
    title([titles(i) 'avg. per student']);
end %add data labels with num of each collision
saveas(gcf,'figure4.fig') % save plot to file
set(figure(4),'visible','off');

% disp('The student data had:')
for i=1:numURMs
    numStudentsInURM=studentsPerURM(i);
    avgScore=colByURMavg(numCollisionTypes+1,i);
%     fprintf('%4d %s students\n         with an avg. overall score of %.3f\n',numStudentsInURM,urmStatus(i),avgScore);
end
% disp('See figure 4 for details of collisions by URM status');
% disp(' ');

% counts of collision type per primary major; average and stdev
major1Names=unique(major1);
uniqueMajor1=unique(major1);
numMajor1s=length(uniqueMajor1);
colByMajor1=zeros(numCollisionTypes+1,numMajor1s);
colByMajor1avg=colByMajor1;
studentsPerMajor1=zeros(1,numMajor1s);
for j=1:numMajor1s %for each student year
    isMajor1=strcmp(major1,uniqueMajor1(j));
    studentsPerMajor1(j)=sum(isMajor1);
    for i=1:numCollisionTypes %count each type of collision for that yr
        colByMajor1(i,j)=sum(isMajor1.*collisionCountsByStudent(:,i));
        colByMajor1avg(i,j)=colByMajor1(i,j)/studentsPerMajor1(j);
    end
    %-calculate the overall score for that year
    colByMajor1(numCollisionTypes+1,j)=dot(colByMajor1(1:numCollisionTypes,j),collisionWeights);
    colByMajor1avg(numCollisionTypes+1,j)=colByMajor1(numCollisionTypes+1,j)/studentsPerMajor1(j);
end
figure(5)
titles=[collisionTypes "Overall Score"];
c=categorical(major1Names);
for i=1:numCollisionTypes+1
    subplot(1,numCollisionTypes+1,i)
    barh(c,colByMajor1avg(i,:));
    title([titles(i) 'avg. per student']);
end %add data labels with num of each collision
saveas(gcf,'figure5.fig') % save plot to file
set(figure(5),'visible','off');

figure(6)
for i=1:numCollisionTypes+1
    subplot(1,numCollisionTypes+1,i)
    barh(c,colByMajor1(i,:));
    title([titles(i) 'total']);
end %add data labels with num of each collision
saveas(gcf,'figure6.fig') % save plot to file
set(figure(6),'visible','off');

% disp('The student data had:')
for i=1:numMajor1s
    numStudentsInMajor1=studentsPerMajor1(i);
    avgScore=colByMajor1avg(numCollisionTypes+1,i);
%     fprintf('%4d %s students\n         with an avg. overall score of %.3f\n',numStudentsInMajor1,char(major1Names(i)),avgScore);
end
% disp('See figure 5 and 6 for details of collisions by primary major');
% disp(' ');

% counts of collision type if double major vs. not; average and stdev

% number of students taking exams in each slot
numStudentsPerDay=zeros(6,7);
for i=1:6
    for j=1:7
        if schedule(i,j) ~= 0
            numStudentsPerDay(i,j)=sum(whichExams(:,schedule(i,j)));
        end
    end
end
disp('The number of students taking exams in each slot are:');
disp('           Su          M          T           W            H           F          Sa')
disp(numStudentsPerDay(1:3,:))
disp('')
disp('           Su          M          T           W            H           F          Sa')
disp(numStudentsPerDay(4:6,:))

% number of students taking their last exam in each slot
% create an array with exams in the schedule order
scheduleOrder=zeros(1,totalNumExams-2);
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
numStudentsLeaving=zeros(6,7);
for i=1:6
    for j=1:7
        if schedule(i,j) ~= 0
            numStudentsLeaving(i,j)=sum(lastExam(:,1)==schedule(i,j));
        end
    end
    numStudentsNoExams=sum(lastExam(:,1)==0);
end

%Calculate number of students leaving each day
n=1;
for i=1:3:6
    for j=1:7
        if sum(numStudentsLeaving(i:i+2,j) ~= 0 )    
        numLeavingbyday(n)=sum(numStudentsLeaving(i:i+2,j));
        n=n+1;
        end   
    end
end

%Calculate number of students who will have left by each day
for i=1:length(numLeavingbyday)
   numHaveleft(i)=sum(numLeavingbyday(1:i));
end


%Calculate average duration of exam period
w_leave=0;
for i=1:length(numLeavingbyday)
    w_leave=w_leave+ i*numLeavingbyday(i);
end

aver_dur = w_leave/sum(numLeavingbyday);
   

        
disp('The number of students that can leave after each exam are:');
disp('           Su          M          T           W            H           F          Sa')
disp(numStudentsLeaving(1:6,:))
disp('The number of students that can leave each day are:');
disp(numLeavingbyday)
disp('The number of students who will have left by each day are:');
disp(numHaveleft)
fprintf('Average duration of the exam period per student is %.2f days\n', aver_dur)

fprintf('There were %d students taking no exams\n',numStudentsNoExams);
end