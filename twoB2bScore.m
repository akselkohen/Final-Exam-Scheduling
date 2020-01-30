% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [numTwoB2bCollisions, numTwoB2bPerStudent, numTwoB2bSlots] = twoB2bScore(schedule, studentData)
    % Calculates the weighted collision "score" for
    % collisions where two exams occur back-to-back in the same day.
    % Does not include days without an exam in the calculation 
    % 
    % Input:
    %   schedule-       generated from createSchedule()
    %   studentData-    a map containing the following variables
    %      whichExams-  an n x m matrix where the n rows represent students
    %                   and the m columns represent exams
    %   
    %
    % Output:
    %   numTwoB2bCollisions-    
    %                   total occurances of two exams b2b
    %   numTwoB2bPerStudent- 
    %                   an n x 1 vector where the value in each row
    %                   represents the number of times that student
    %                   experiences a twoB2b collision
    %   numTwoB2bSlots- the number of times in the schedule that exams
    %                   could create this collision type
    whichExams=studentData('whichExams');
    
    numStudents=size(whichExams,1);
    numTwoB2bPerStudent=zeros(numStudents,1);
    numTwoB2bSlots= 0; 
    
    for i=1:size(schedule,2) % each weekday
        for j=1:3:size(schedule,1) % each day occuring on that weekday
            % consider the exams scheduled in each slot
            slot1=schedule(j,i);
            slot2=schedule(j+1,i);
            slot3=schedule(j+2,i);
            % if the first two slots have exams
            if (slot1 ~= 0 && slot2 ~= 0)
                numTwoB2bSlots=numTwoB2bSlots+1;
                numTwoB2bPerStudent = numTwoB2bPerStudent + whichExams(:,slot1).*whichExams(:,slot2);
            end
            if (slot2 ~= 0 && slot3 ~= 0)
                numTwoB2bSlots=numTwoB2bSlots+1;
                numTwoB2bPerStudent = numTwoB2bPerStudent + whichExams(:,slot2).*whichExams(:,slot3);
            end
        end
    end
    numTwoB2bCollisions=sum(numTwoB2bPerStudent);
end
