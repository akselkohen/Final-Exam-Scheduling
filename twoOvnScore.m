% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [numTwoOvnCollisions, numTwoOvnPerStudent, numTwoOvnSlots] = twoOvnScore(schedule, studentData)
    % Calculates the weighted collision "score" for
    %collisions where two exams occur in the last(third) slot of one day and the
    %first slot of the following day. 
    % Does not include days when the last slot is the second slot
    % Does not include days without an exam in the calculation 
    % 
    % Input:
    %   schedule-       generated from createSchedule()
    %   studentData-        a map containing the following variables
    %      whichExams-  an n x m matrix where the n rows represent students
    %                   and the m columns represent exams
    %   
    %
    % Output:
    %   numTwoOvnCollisions-    
    %                   total occurances of two exams overnight
    %   numTwoOvnPerStudent- 
    %                   an n x 1 vector where the value in each row
    %                   represents the number of times that student
    %                   experiences a twoOvn collision
    %   numTwoOvnSlots- the number of times in the schedule that exams
    %                   could create this collision type
    whichExams=studentData('whichExams');
    
    numStudents=size(whichExams,1);
    numTwoOvnPerStudent=zeros(numStudents,1);
    numTwoOvnSlots= 0; 
            
    for i=1:size(schedule,2)-1
        for j=3:3:size(schedule,1)
            slot3day1=schedule(j,i);
            slot1day2=schedule(j-2, i+1);
            if (slot3day1 ~= 0 && slot1day2 ~= 0)
                numTwoOvnSlots=numTwoOvnSlots+1;
                numTwoOvnPerStudent=numTwoOvnPerStudent + whichExams(:,slot3day1).*whichExams(:,slot1day2);
            end
        end
    end
    numTwoOvnCollisions=sum(numTwoOvnPerStudent);

end