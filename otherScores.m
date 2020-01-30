% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function otherScore = otherScores(schedule,studentData,templateData,scoringOptions)

%unpack student data
whichExams=studentData('whichExams');
%unpack template data
constrExams=templateData('constrExams');
numConstrExams=length(constrExams);
earlyExams=templateData('earlyExams');
numEarlyExams=length(earlyExams);

%unpack scoring information
otherTypes=scoringOptions('otherTypes');      %["studentsDoneEarly","earlyExamsMet"];
whichOtherScores=scoringOptions('whichOtherScores'); %[       0           ,        0      ];
otherWeights=scoringOptions('otherWeights'); %[      0.1          ,      100      ];
sdeWeight=otherWeights(1,1);
eemWeight=otherWeights(1,2);
friWeight=otherWeights(1,3);

if whichOtherScores(1,1)==1 && whichOtherScores(1,2)==1
    sdeScore=studentsDoneEarlyScore(schedule,whichExams,sdeWeight);
    eemScore=earlyExamsMetScore(schedule,earlyExams,eemWeight);
    friScore=friEveScore(schedule, whichExams,friWeight);
    otherScore=sdeScore+eemScore + friScore;
elseif whichOtherScores(1,1)==1 && whichOtherScores(1,2)==0 
    sdeScore=studentsDoneEarlyScore(schedule,whichExams,sdeWeight);
    friScore=friEveScore(schedule, whichExams,friWeight);
    otherScore=sdeScore + friScore;
elseif whichOtherScores(1,1)==0 && whichOtherScores(1,2)==1
    eemScore=earlyExamsMetScore(schedule,earlyExams,eemWeight);
    friScore=friEveScore(schedule, whichExams,friWeight);
    otherScore=eemScore + friScore;
else
    friScore=friEveScore(schedule, whichExams,friWeight);
    otherScore=friScore;
end



end


