% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [numTwoWbCollisions, numTwoWbPerStudent, numTwoWbSlots] = twoWbScore(schedule, studentData)
    % Calculates the weighted collision "score" for
    % collisions where two exams occur back-to-back in the same day.
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
    %   numTwoWbCollisions-    
    %                   total occurances of two exams with a break (Wb)
    %   numTwoWbPerStudent- 
    %                   an n x 1 vector where the value in each row
    %                   represents the number of times that student
    %                   experiences a twoWb collision
    %   numTwoWbSlots-  the number of times in the schedule that exams
    %                   could create this collision type
    whichExams=studentData('whichExams');
    
    numStudents=size(whichExams,1);
    numTwoWbPerStudent=zeros(numStudents,1);
    numTwoWbSlots= 0; 
            
    for i=1:size(schedule,2)
        for j=1:3:size(schedule,1)
            slot1=schedule(j,i);
            slot3=schedule(j+2, i);
            
            if (slot1 ~= 0 && slot3 ~= 0)
                numTwoWbSlots=numTwoWbSlots+1;
                numTwoWbPerStudent=numTwoWbPerStudent + whichExams(:,slot1).*whichExams(:,slot3);
            end
        end
    end
    numTwoWbCollisions=sum(numTwoWbPerStudent);

end
