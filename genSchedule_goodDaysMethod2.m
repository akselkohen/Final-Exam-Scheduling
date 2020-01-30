% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function schedule= genSchedule_goodDaysMethod2(studentData,templateData,scoringOptions, allowableThreeB2b, forbiddenpairs, crucialtriples,crucialpairs,maxthreetotal, sampleSize,giveSummary)
tic;
%Unpack studentData
collisionMatrix=studentData('collisionMatrix');
collisionTensor=studentData('collisionTensor');
examNames=studentData('examNames');
whichExams=studentData('whichExams');
numStudents=size(whichExams,1);
totalNumExams=size(whichExams,2);

%Unpack templateData
fullTemplate=templateData('fullTemplate');
% workingTemplate=templateData('workingTemplate');
constrTemplate=templateData('constrTemplate');
oriConstrTemplate=constrTemplate;
constrExams=templateData('constrExams');
% constrOriTemplate=constrTemplate;
numConstrExams=length(constrExams);

%Unpack scoringOptions
collisionWeights=scoringOptions('collisionWeights');
w_twoB2b=collisionWeights(1);
w_twoWb=collisionWeights(2);
w_twoOvn=collisionWeights(3);
w_threeB2b=collisionWeights(4);
w_threeOvn=collisionWeights(5);


%set up boolean for Merged
mergeTest=0; %0 indicating no merging


%%  Merge (Constrained) Evening Exams
poss_merg=combnk(constrExams,3);

% Check which three evening exams to combine
min_conf=10^6;
for i=1:size(poss_merg,1)
    stu_conf=collisionMatrix(poss_merg(i,1),poss_merg(i,2))+ collisionMatrix(poss_merg(i,1),poss_merg(i,3)) + collisionMatrix(poss_merg(i,2),poss_merg(i,3)) - 2 * collisionTensor(poss_merg(i,1),poss_merg(i,2),poss_merg(i,3));

  if stu_conf < min_conf
      min_conf=stu_conf;
      mer_1=poss_merg(i,1);
      mer_2=poss_merg(i,2); 
      mer_3=poss_merg(i,3);
  end
end

%  Combine the three evening exams 
whichExams(:,mer_1)=whichExams(:,mer_1)+ whichExams(:,mer_2) + whichExams(:,mer_3);
whichExams(:,mer_2)=0;
whichExams(:,mer_3)=0;

% Update template data

[mer2_row , mer2_col]=find(constrTemplate==mer_2);
constrTemplate(mer2_row,mer2_col)=0;
[mer3_row , mer3_col]=find(constrTemplate==mer_3);
constrTemplate(mer3_row,mer3_col)=0;
[mer2_ind]=find(constrExams==mer_2);
constrExams(mer2_ind)=[];
[mer3_ind]=find(constrExams==mer_3);
constrExams(mer3_ind)=[];



%Remove exam slots from the end of the template. Since some exams have been
%merged, these slots are superflous. 
OriFullTemplate=fullTemplate;
[x y]=find(fullTemplate(4:6,:),2,'last');

save=[];
tempFullTemplate=fullTemplate;
for i=1:length(x)%do not remove slot  if the slot contains a fixed exam
  if constrTemplate(x(i)+3,y(i))~=0 
      tempFullTemplate(x(i)+3,y(i))=0; 
      save=[save x(i) ; y(i)]; %save for restoring later
  end    
end
fullTemplate=tempFullTemplate;
[x y]=find(fullTemplate(4:6,:),2,'last');
fullTemplate(x(1)+3, y(1))=0;
fullTemplate(x(2)+3, y(2))=0;

% Restore any previously removed constraiened exam 
for i=1:size(save,2)
    fullTemplate(save(1,i)+3,save(2,i))=1;
end


%Update exam names

examNames(mer_1)= examNames(mer_1)+ " & " + examNames(mer_2) + " & " + examNames(mer_3);
examNames(mer_2)=0;
examNames(mer_3)=0;


% %Identify and count the students with conflicts
% %Assume these students will be accomodated seperately

stu=find(whichExams(:,mer_1)>1);
min_conf;
length(stu);
whichExams(stu,mer_1)=1;
mergedExams=[mer_1, mer_2, mer_3];

% %Update container with merged data
studentData("whichExams")=whichExams;
studentData("examNames")=examNames;
studentData("constrTemplate")=constrTemplate;

% %Update collision Tensor and Matrix
[collisionMatrix, collisionTensor]=studentCollisions(whichExams);


mergeTest=1; %1 indicating merging has taken place


%% Types disallowed
%Fixed exams can only appear in certain types of days. Indicate the type for
%each fixed exam in a vector
typesdisallowed=[];

for i=1:length(constrExams)
    [x,y]=find((constrTemplate==constrExams(i)));
    if x < 4
        new_type=sum(fullTemplate(1:3,y));
    else
        new_type=sum(fullTemplate(4:6,y));
    end
    if new_type==1
        typesdisallowed=[typesdisallowed ; [constrExams(i) 2]];
        typesdisallowed=[typesdisallowed ;[constrExams(i) 3]];
    elseif new_type==2
        typesdisallowed=[typesdisallowed ;[constrExams(i) 1]];
        typesdisallowed=[typesdisallowed ;[constrExams(i) 3]];

    else
        typesdisallowed=[typesdisallowed ;[constrExams(i) 1]];
        typesdisallowed=[typesdisallowed ;[constrExams(i) 2]];
        
    end
end


%% Count days
% tDays (T): days with three exams to be scheduled
% dDays (D): days with two exams to be scheduled
% sDays (S): days with one exam to be scheduled
%count how many tDays, dDays, sDays we need
numTDaySlots=0;
numDDaySlots=0;
numSDaySlots=0;
for i=[1 4]
    for j=1:7
        if sum(fullTemplate(i:i+2,j))==3
            numTDaySlots=numTDaySlots+1;
        elseif sum(fullTemplate(i:i+2,j))==2
            numDDaySlots=numDDaySlots+1;
        elseif sum(fullTemplate(i:i+2,j))==1
            numSDaySlots=numSDaySlots+1;
        end
    end
end
numDaySlots=numTDaySlots+numDDaySlots+numSDaySlots; 


%% Assign penalty in conflict matrix/tensor for matching i,j forbidden pair
% (as if infinite students had that i,j pair but not actually)

[rr,~]=size(forbiddenpairs);
for i=1:rr
    q=sort(forbiddenpairs(i,:));
    collisionMatrix(q(1),q(2))=10000;
    for j=1:totalNumExams
        q=sort([j forbiddenpairs(i,:)]);
        collisionTensor(q(1),q(2),q(3))=inf;
    end
end

%% Find Trios of Exams with few threeb2b collisions
% These trios of exams can be used to schedule days needing three exams (TDays)
 
% Preallocate space for the scenario all trios with i<j<k have an allowable
%number of threeb2b collisions
maxNumGoodTDays=0;
for i=1:(totalNumExams-1)
    maxNumGoodTDays=maxNumGoodTDays+(i*(totalNumExams-i-1));
end
maxGoodTDays=zeros(3,maxNumGoodTDays);

% Create an array containing all the trios of exams with few three-way conflicts
n=1; %track which spaces in goodTDays are filled
for i=1:totalNumExams %iterate through the tensor, avoiding permuatations of the same triple
    for j=i+1:totalNumExams
        for k=j+1:totalNumExams
            if collisionTensor(i,j,k)<=allowableThreeB2b
                maxGoodTDays(:,n)= [i;j;k];
                n=n+1;
            end
        end
    end
end

% Eliminate uneeded spaces
numGoodTDays=n-1;
goodTDays=maxGoodTDays(:,1:numGoodTDays);

%% Find all Pairs of Exams
% These pairs of exams can be used to schedule days needing two exams(DDays)

numGoodDDays=nchoosek(totalNumExams,2);
goodDDays=zeros(2,numGoodDDays);
z=1;
for i=1:totalNumExams %iterate while avoiding permuatations of the same double
    for j=i+1:totalNumExams
        goodDDays(:,z)=[i; j];
        z=z+1;
    end
end
%% Find all Single Exams
% These exams can be used to schedule days where one exam is offered (SDays)
% Exclude constrained exams and assign a placeholder score of zero

% numGreatSDays=totalNumExams-numConstrExams;
% greatSDays=zeros(1,numGreatSDays);

goodSDays=zeros(1,totalNumExams);
numGoodSDays=totalNumExams;
goodSDay_IntraScores=goodSDays;

% j=1;
for i=1:totalNumExams
%     if ~ismember(i,constrExams)
        goodSDays(1,i)=i;
%         j=j+1;
%     end
end

%% Deal with Crucial pairs
% DEALING WITH CRUCIAL PAIRS:
% delete columns of goodDDays and goodTDays involving only 1 of each crucial pair value
[cp,~]=size(crucialpairs);
for i=1:cp
    q=sort(crucialpairs(i,:));
    [~,b]=find(goodDDays==q(1));
    goodDDays(:,b)=[];
    [~,b]=find(goodDDays==q(2));
    goodDDays(:,b)=[];
    [~,b]=find(goodTDays==q(1));
    goodTDays(:,b)=[];
    [~,b]=find(goodTDays==q(2));
    goodTDays(:,b)=[];
end
% restore goodDDays and goodTDays only with crucial pairs
for i=1:cp
%     q=sort(crucialpairs(i,:));
%     goodDDays=[goodDDays [q(1) q(2)]'];
    for i=1:totalNumExams
        if i~=q(1) && i~=q(2)
            if collisionTensor(i,q(1),q(2))<=allowableThreeB2b
                triple=[i q(1) q(2)];
                triple=sort(triple);
                goodTDays=[goodTDays triple'];
            end
        end
    end
end


%% Dealing with crucial triples
% delete columns of goodDDays and goodTDays w/ triple values, then restore triple
[ct,~]=size(crucialtriples);
for k=1:ct
    q=sort(crucialtriples(k,:));
    [~,b]=find(goodDDays==q(1));
    goodDDays(:,b)=[];
    [~,b]=find(goodDDays==q(2));
    goodDDays(:,b)=[];
    [~,b]=find(goodDDays==q(3));
    goodDDays(:,b)=[];
    [~,b]=find(goodTDays==q(1));
    goodTDays(:,b)=[];
    [~,b]=find(goodTDays==q(2));
    goodTDays(:,b)=[];
    [~,b]=find(goodTDays==q(3));
    goodTDays(:,b)=[];
    goodTDays=[goodTDays q'];
end

[~,numGoodDDays]=size(goodDDays);
[~,numGoodTDays]=size(goodTDays);



%% Score goodTDays 
% Arrange exams within a goodTDay so that the pairing with the most 
%students taking those two exams is separated
% Score the goodTDays based on within-day or intra-day collisions,
%ie weighted twoB2b, twoWb, threeb2b


% tempScore=zeros(1,numGoodTDays);

goodTDay_IntraScores=zeros(1,numGoodTDays);

for i=1:numGoodTDays %For each possible day of three exams)
    TDay=goodTDays(:,i); %Isolate a day to manipulate
 
    tempT=TDay;
    isConstr=ismember(goodTDays(:,i), constrExams);
      if sum(isConstr)==0
        % Run Paige's method of calculating objective function
        onetwo=collisionMatrix(goodTDays(1,i),goodTDays(2,i));
        onethree=collisionMatrix(goodTDays(1,i),goodTDays(3,i));
        twothree=collisionMatrix(goodTDays(2,i),goodTDays(3,i));
%         onetwothree=collisionTensor(goodTDays(1,i),goodTDays(2,i),goodTDays(3,i));
        
        conflicts=[onetwo,twothree,onethree];
        if max(conflicts)==onetwo
            goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+w_twoB2b*(twothree+onethree)+w_twoWb*onetwo;% + w_threeB2b*onetwothree;
            
            %TDay(1)=tempT(1);
            TDay(2)=tempT(3);
            TDay(3)=tempT(2);
            
         elseif max(conflicts)==twothree
            goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+w_twoB2b*(onetwo+onethree)+w_twoWb*twothree;% + w_threeB2b*onetwothree;
            TDay(1)=tempT(2);
            TDay(2)=tempT(1);
%           %triple(3)=temp(3);
        else % max(conflicts)==onethree
            goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+w_twoB2b*(onetwo+twothree)+w_twoWb*onethree;% + w_threeB2b*onetwothree;
        end
    elseif sum(isConstr)==1 % if triplet contains one constrained exam
        cIndex=find(isConstr==1);
        nonIndex=find(isConstr==0);
        [constrRow,~]=find(constrTemplate==goodTDays(cIndex,i));
        if constrRow>3
            constrRow=constrRow-3;
        end
        
        onetwo=collisionMatrix(goodTDays(cIndex,i),goodTDays(nonIndex(1),i));
        twothree=collisionMatrix(goodTDays(cIndex,i),goodTDays(nonIndex(2),i));
        onethree=collisionMatrix(goodTDays(nonIndex(1),i),goodTDays(nonIndex(2),i));
%         onetwothree=collisionTensor(goodTDays(1,i),goodTDays(2,i),goodTDays(3,i));
        if constrRow==1
         TDay(1)=tempT(cIndex);
         TDay(cIndex)=tempT(1);
       
        elseif constrRow==2
         TDay(2)=tempT(cIndex);
         TDay(cIndex)=tempT(2);  
        else %constrRow==3
         TDay(3)=tempT(cIndex);
         TDay(cIndex)=tempT(3); 
        end
 
        if constrRow==2
            goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+w_twoB2b*(onetwo+twothree)+w_twoWb*onethree;% + w_threeB2b*(onetwothree);
        else
            if onetwo>twothree
                goodTDay_IntraScores(i)=goodTDay_IntraScores(+i)+w_twoB2b*(onethree+twothree)+w_twoWb*onetwo;% + w_threeB2b*(onetwothree);
            else
                goodTDay_IntraScores(+i)=goodTDay_IntraScores(i)+w_twoB2b*(onethree+onetwo)+w_twoWb*twothree;% + w_threeB2b*(onetwothree);
            end
        end
    elseif sum(isConstr)==2 % if triplet contains two constrained exams
        cIndex=find(isConstr==1);
        nonIndex=find(isConstr==0);
        [constrRow1,constrCol1]=find(constrTemplate==goodTDays(cIndex(1),i));
        [constrRow2,constrCol2]=find(constrTemplate==goodTDays(cIndex(2),i));

        if constrCol1==constrCol2 % confirmed exams are same column i.e. crucial pair, else forbidden pair
            % haven't tested if this part of the code works yet....
            onetwo=collisionMatrix(goodTDays(cIndex(1),i),goodTDays(nonIndex,i));
            twothree=collisionMatrix(goodTDays(cIndex(2),i),goodTDays(nonIndex,i));
            onethree=collisionMatrix(goodTDays(cIndex(1),i),goodTDays(cIndex(2),i));
%             onetwothree=collisionTensor(goodTDays(1,i),goodTDays(2,i),goodTDays(3,i));

            if constrRow1==2
                goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+w_twoB2b*(onetwo+onethree)+w_twoWb*twothree; %%+ w_threeB2b*(onetwothree);
            elseif constrRow2==2
                goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+w_twoB2b*(twothree+onethree)+w_twoWb*onetwo; %+ w_threeB2b*(onetwothree);
            else
                goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+w_twoB2b*(onetwo+twothree)+w_twoWb*onethree; %+ w_threeB2b*(onetwothree);
            end
        end
      end
      
     goodTDay_IntraScores(i)=goodTDay_IntraScores(i)+ w_threeB2b*collisionTensor(goodTDays(1,i),goodTDays(2,i),goodTDays(3,i));
     goodTDays(:,i)=TDay;
end




%% Score goodDDays under consideration 



goodDDay_IntraScores=zeros(1,numGoodDDays);
for i=1:numGoodDDays
    DDay=goodDDays(:,i);
    tempD=DDay;
    isConstr=ismember(DDay,constrExams);
    if sum(isConstr)==1
        cIndex=find(isConstr==1);
        [constrRow,~]=find(constrTemplate==DDay(cIndex));
        if constrRow>3
            constrRow=constrRow -3;
        end
        if constrRow==1
            DDay(1)=tempD(cIndex);
            DDay(cIndex)=tempD(1);
        end  
         if constrRow==2
            DDay(2)=tempD(cIndex);
            DDay(cIndex)=tempD(2);
        end
       
    end
    
    goodDDays(:,i)=DDay;
        
        goodDDay_IntraScores(1,i)=w_twoB2b*collisionMatrix(goodDDays(1,i),goodDDays(2,i));

end




%% Find Feasible Set of Days to Fill The Template
% Create adjacency matrix
numGoodDays=numGoodSDays+numGoodDDays+numGoodTDays;
A=zeros(totalNumExams+3,numGoodDays);
% put 1's in rows corresponding to exams in the potential/'great' TDays
for i=1:numGoodTDays
    curTDay=goodTDays(:,i);
    A(totalNumExams+1,i)=1; %keep track of the fact this column contains a Tday
    for k=1:3
        A(curTDay(k,1),i)=1;
    end
end
%  put 1's in rows corresponding to exams in the potential/'great' Ddays
for i=numGoodTDays+1:numGoodTDays+numGoodDDays
    curDDay=goodDDays(:,i-numGoodTDays);
     A(totalNumExams+2,i)=1; %keep track of the fact this column contains a DDay
    for k=1:2
        A(curDDay(k,1),i)=1;
    end
end
% put 1's in rows corresponding to exams in the potential/'great' Sdays
for i=numGoodTDays+numGoodDDays+1:numGoodDays
    A(totalNumExams+3,i)=1; %keep track of the fact this column contains a SDay
    A(goodSDays(1,i-numGoodTDays-numGoodDDays),i)=1;
end

 % the solution should have each exam appear once, 
b=ones(totalNumExams+3,1);
for i=2:length(mergedExams)
    b(mergedExams(i))=0; % If we don't want to use certain exams, assign them zero
end
% for i=1:numConstrExams
%     b(constrExams(i))=0;
% end

% the solution should contain the needed number of TDays, DDays, and SDays
%to fill the template
b(totalNumExams+1,1)=numTDaySlots;
b(totalNumExams+2,1)=numDDaySlots;
b(totalNumExams+3,1)=numSDaySlots;
% purpose of Ain and bin: Ain * x < bin
% ensures less than 3 people overall have 3 tests on a day


Ain=zeros(1,numGoodDays);
bin=maxthreetotal;
for i=1:numGoodTDays
    Ain(1,i)=collisionTensor(goodTDays(1,i),goodTDays(2,i),goodTDays(3,i));
end   

% types disallowed: exam types not allowed on single, pair, or triplet
[rr,~]=size(typesdisallowed);
for i=1:rr
    if typesdisallowed(i,2)==1
        for j=1:numGoodSDays
        A(typesdisallowed(i,1),numGoodTDays+numGoodDDays+j)=0; 
        end% manipulate Aeq
    elseif typesdisallowed(i,2)==2
        for j=1:numGoodDDays
            A(typesdisallowed(i,1),numGoodTDays+j)=0;
        end
    else
        for j=1:numGoodTDays
            A(typesdisallowed(i,1),j)=0;
        end
    end
end

lb=zeros(numGoodDays,1);
ub=ones(numGoodDays,1);
f=[goodTDay_IntraScores goodDDay_IntraScores goodSDay_IntraScores]';
intcon=1:numGoodDays;

options=optimoptions(@intlinprog,'display','off'); %supress the display
x=intlinprog(f,intcon,Ain,bin,A,b,lb,ub);

% Condense feasible solution into schedule 
ansInd=find(x>0.999); %note: intlinprog sometimes has small error in 1's
chosenTDays=zeros(3,numTDaySlots);
chosenDDays=zeros(2,numDDaySlots);
chosenSDays=zeros(1,numSDaySlots);

% store chosen triples
for i=1:numTDaySlots
    chosenTDays(:,i)=goodTDays(:,ansInd(i));
end
% store chosen doubles
for i=1:numDDaySlots
    chosenDDays(:,i)=goodDDays(:,ansInd(i+numTDaySlots)-numGoodTDays);
end
% store singles
for i=1:numSDaySlots
    chosenSDays(:,i)=goodSDays(:,ansInd(i+numTDaySlots+numDDaySlots)-numGoodTDays-numGoodDDays);
end



%% Scoring 
% Generate a (sample) schedule, for now. 
schedule = createScheduleFromDays(fullTemplate, chosenTDays, chosenDDays, chosenSDays,constrExams, constrTemplate); %+ constrTemplate;
% scoring function
schedScore = scoreFunction(schedule,studentData,templateData,scoringOptions);

%% Sample Arrangements of ChosenDays (Flips and Permuations), Choose Lowest Scoring
% User Input: Sampling Parameters
% sampleSize 
numToStore = 10;

%Preallocate space for lowestScoringSchedules
lowScoreScheds = zeros(numToStore,1+size(fullTemplate,1)*size(fullTemplate,2));
% Store all of the scores to generate histogram
allScores=zeros(sampleSize,1);


if numDaySlots <= 5
    % do nothing for now
    % in the future, we'll want to enumerate all possibilities
else
            numStored = 1; %note that this name can be confusing in terms of indexing
             for i=1:sampleSize
                 if numStored <= numToStore %then we don't need to compare scores yet
                            %create a random permutation of a schedule (function)
                                % sample a triple arrangement
                                    %make an arrangement (perm and flip) of triples
                                    tripArrange=chosenTDays*0;
                                    tripPermInd=randperm(numTDaySlots);
                                    flipInd=randi([0 1],1,numTDaySlots);                  
                                    for j=1:numTDaySlots
                                        tripArrange(:,j)=chosenTDays(:,tripPermInd(j));
                                        if flipInd(j)==1
                                            top=tripArrange(1,j);
                                            tripArrange(1,j)=tripArrange(3,j);
                                            tripArrange(3,j)=top;
                                        end
                                    end

                                    %make an arrangement (perm and flip) of doubles
                                    clear flipInd;
                                    doubArrange=chosenDDays*0;
                                    doubPermInd=randperm(numDDaySlots);
                                    flipInd=randi([0 1],1,numDDaySlots);                      
                                    for j=1:numDDaySlots
                                        doubArrange(:,j)=chosenDDays(:,doubPermInd(j));
                                        if flipInd(j)==1
                                            top=doubArrange(1,j);
                                            doubArrange(1,j)=doubArrange(2,j);
                                            doubArrange(2,j)=top;
                                        end
                                    end

                                    %make an arrangement (perm only) of singles
                                    singleArrange=chosenSDays*0;
                                    singlePermInd=randperm(numSDaySlots);                                   
                                    for j=1:numSDaySlots
                                        singleArrange(1,j)=chosenSDays(:,singlePermInd(j));
                                    end
                                % combine into template
                                schedArrangement=createScheduleFromDays(fullTemplate,tripArrange,doubArrange,singleArrange, constrExams, constrTemplate);
                                %score with constrained exams added back
%                               %schedArrangment=schedArrangement+constrTemplate;
                                scoreArrange=scoreFunction(schedArrangement,studentData,templateData,scoringOptions);
                                %store the arrangment (constrained exams included)and the score
                                %make the schedule a vector for easy storage
                                schedArrangeVect=reshape(schedArrangement,[1,size(fullTemplate,1)*size(fullTemplate,2)]);
                                %store in lowScoreScheds at numStored
                                lowScoreScheds(numStored,1)=scoreArrange;
                                allScores(numStored,1)=scoreArrange;
                                lowScoreScheds(numStored,2:end)=schedArrangeVect;
                        else %we'll need to only store if the score is lower
                                % create a random permutation of a schedule (function)
                                % sample a triple arrangement
                                    %make an arrangement (perm and flip) of triples
                                    tripArrange=chosenTDays*0;
                                      tripPermInd=randperm(numTDaySlots);
                                     flipInd=randi([0 1],1,numTDaySlots);       
                                    for j=1:numTDaySlots
                                        tripArrange(:,j)=chosenTDays(:,tripPermInd(j));
                                        if flipInd(j)==1
                                            top=tripArrange(1,j);
                                            tripArrange(1,j)=tripArrange(3,j);
                                            tripArrange(3,j)=top;
                                        end
                                    end

                                    %make an arrangement (perm and flip) of doubles
                                    clear flipInd;
                                    doubArrange=chosenDDays*0;
                                    doubPermInd=randperm(numDDaySlots);
                                    flipInd=randi([0 1],1,numDDaySlots);                     
                                    for j=1:numDDaySlots
                                        doubArrange(:,j)=chosenDDays(:,doubPermInd(j));
                                        if flipInd(j)==1
                                            top=doubArrange(1,j);
                                            doubArrange(1,j)=doubArrange(2,j);
                                            doubArrange(2,j)=top;
                                        end
                                    end

                                    %make an arrangement (perm only) of singles
                                    singleArrange=chosenSDays*0;
                                    singlePermInd=randperm(numSDaySlots);
                                    for j=1:numSDaySlots
                                        singleArrange(1,j)=chosenSDays(:,singlePermInd(j));
                                    end

                                % combine into template
                                schedArrangement=createScheduleFromDays(fullTemplate,tripArrange,doubArrange,singleArrange,constrExams, constrTemplate);
                                %score with constrained exams added back
%                               %schedArrangment=schedArrangement+constrTemplate;
                                scoreArrange=scoreFunction(schedArrangement,studentData,templateData,scoringOptions);
                                allScores(numStored,1)=scoreArrange;

                                %store the arrangement and score if its better (constrained exams included)
                                %find the worst schedule in the list
                                [maxStoredScore,maxSSRow]=max(lowScoreScheds(:,1));
                                if scoreArrange < maxStoredScore
                                %make the schedule a vector for easy storage
                                schedArrangeVect=reshape(schedArrangement,[1,size(fullTemplate,1)*size(fullTemplate,2)]);
                                %store in lowScoreScheds at location for replacement
                                lowScoreScheds(maxSSRow,1)=scoreArrange;
                                lowScoreScheds(maxSSRow,2:end)=schedArrangeVect;
                                end %comparison to decide storage or not
                        end % if less than num to score
                        numStored = numStored + 1;
                    
          end % if numPossDays condition
end

%% Output the best schedule
[bestScore,rowNum]=min(lowScoreScheds(:,1));
schedule=reshape(lowScoreScheds(rowNum,2:end),6,7); %+constrTemplate;

%% Output Summary Information on the Scheduling Process
time=toc;
fprintf('The good days method completed in %f minutes\n',time/60);

if giveSummary ==1
    % Given Template
    disp('The given template was:')
    disp('     Su    M     T     W     H     F     Sa')
    disp(OriFullTemplate(1:3,:))
    disp('')
    disp('     Su    M     T     W     H     F     Sa')
    disp(OriFullTemplate(4:6,:))
    % Constrained Template
    disp('The following exams were preconstrained:')
    disp('     Su    M     T     W     H     F     Sa')
    disp(constrTemplate(1:3,:))
    disp('')
    disp('     Su    M     T     W     H     F     Sa')
    disp(constrTemplate(4:6,:))

    % Number of threeb2b conflicts allowed per day
    fprintf('You chose to allow up to %d instances of students with three exams in one day, per day.\n',allowableThreeB2b)
    disp(' ')
    
    %Merging of constrained exams
    if mergeTest==1
    fprintf('Exams %d and %d have been merged with exam %d\n',mergedExams(2),mergedExams(3),mergedExams(1))
    fprintf('Merging resulted in %d exam conflicts\n',min_conf)
    end
    disp(' ')


    % Number of TDays, DDays, and SDays Considered
    disp('Based on student data and constrained exams,')
    fprintf('%5d days with three exams were considered\n',numGoodTDays)
    fprintf('%5d days with two exams were considered\n',numGoodDDays)
    fprintf('%5d days with one exam were considered\n',numGoodSDays)
    disp(' ')
    % Optimal Intraday Score
    fprintf('The optimal intraday score was: %f\n',f'*x)
    % Optimal Days
    disp('The days with minimal intraday score were: ')
    fprintf('%3d days with three exams\n',numTDaySlots)
    disp(chosenTDays)
    fprintf('%3d days with two exams\n',numDDaySlots)
    disp(chosenDDays)
    fprintf('%3d days with one exam\n',numSDaySlots)
    disp(chosenSDays)
    disp(' ')
    % Number of Arrangements Sampled; Score Avg and Stdev
    fprintf('There were %d arrangements sampled with\n',sampleSize)
    fprintf('Average: %f\n',mean(allScores))
    fprintf('Standard Deviation: %f\n', std(allScores))
    disp('See figure 1 for a histogram of scores')
    disp(' ')
    % Histogram of Arrangement Scores
    figure(1);
    histogram(allScores);
    title('Sampled Arrangement Scores');
    saveas(gcf,'Fig1_goodDaysSamplingHistogram.fig') % save plot to file
    set(figure(1),'visible','off');
end

end %genSchedule_goodDaysMethod function