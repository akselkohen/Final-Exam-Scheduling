% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function schedule= genSchedule_monteCarloMethod (studentData,templateData,scoringOptions,sampleSize,giveSummary)
%unpack student data
whichExams=studentData('whichExams');
totalNumExams=size(whichExams,2);

% unpack templateData
workingTemplate=templateData('workingTemplate');
constrTemplate=templateData('constrTemplate');
constrExams=templateData('constrExams');

% find which exams are 'flexible' and need scheduling
allExams=1:totalNumExams;
flexExams=setdiff(allExams,constrExams);
numFlexExams=length(flexExams);

% sample schedules, choose lowest scoring
numToStore=10;
lowScoreScheds = zeros(numToStore,1+6*7);
allScores=zeros(sampleSize,1);
numStored=1; %note that this is actually one greater than the number stored
for i=1:sampleSize
    if numStored <= numToStore
        % create a random arrangemnt of the flexible exams
        flexExamsArrange=0*flexExams;
        examPermInd=randperm(numFlexExams);
        for i=1:numFlexExams
            flexExamsArrange(1,i)=flexExams(1,examPermInd(i));
        end
        schedArrange= createScheduleFromExams(workingTemplate,flexExamsArrange);
        schedArrange=schedArrange+constrTemplate;

        % score and store the score
        scoreArrange=scoreFunction(schedArrange,studentData,templateData,scoringOptions);
        allScores(numStored,1)=scoreArrange;

        % also store the score with the schedule
        schedArrangeVect=reshape(schedArrange,[1,6*7]);
        lowScoreScheds(numStored,1)=scoreArrange;
        lowScoreScheds(numStored,2:end)=schedArrangeVect;
    
    else %numStored > numToStore
        % create a random arrangemnt of the flexible exams
        flexExamsArrange=0*flexExams;
        examPermInd=randperm(numFlexExams);
        for i=1:numFlexExams
            flexExamsArrange(1,i)=flexExams(1,examPermInd(i));
        end
        schedArrange= createScheduleFromExams(workingTemplate,flexExamsArrange);
        schedArrange=schedArrange+constrTemplate;            

        % score and store the score
        scoreArrange=scoreFunction(schedArrange,studentData,templateData,scoringOptions);
        allScores(numStored,1)=scoreArrange;

        %then only store more if its lower scoring
        [maxStoredScore,maxSSRow]=max(lowScoreScheds(:,1));
        if scoreArrange < maxStoredScore
            schedArrangeVect=reshape(schedArrange,[1,size(workingTemplate,1)*size(workingTemplate,2)]);
            %store in lowScoreScheds at location for replacement
            lowScoreScheds(maxSSRow,1)=scoreArrange;
            lowScoreScheds(maxSSRow,2:end)=schedArrangeVect;
        end %comparison to decide storage or not

    end %conditional for storage
    numStored=numStored+1;
end %end sampling

% output the best schedule
[bestScore,rowNum]=min(lowScoreScheds(:,1));
schedule=reshape(lowScoreScheds(rowNum,2:end),6,7);

% summarize results if asked for
if giveSummary==1
    histogram(allScores)
end

end