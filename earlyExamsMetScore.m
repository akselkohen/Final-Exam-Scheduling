% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [eemScore, earlyExamsNotMet]= earlyExamsMetScore(schedule,earlyExams,eemWeight)
numEarlyExams=length(earlyExams);
eemScore=0;
earlyExamsNotMet=[];
for i=1:numEarlyExams
    if ~ismember(earlyExams(1,i),schedule(1:3,1:4))
        earlyExamsNotMet=[earlyExamsNotMet, earlyExams(i)];
        eemScore=eemScore+eemWeight;
    end
end

end