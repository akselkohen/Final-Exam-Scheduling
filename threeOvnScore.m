% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [numThreeOvnCollisions, numThreeOvnPerStudent, numThreeOvnSlots] = threeOvnScore(schedule, studentData)
    % Calculates the weighted collision "score" for
    %collisions where three exams occur in close proximity on two days.
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
    %   numThreeOvnCollisions-    
    %                   total occurances of three exams in two days
    %   numThreeOvnPerStudent- 
    %                   an n x 1 vector where the value in each row
    %                   represents the number of times that student
    %                   experiences a threeOvn collisions
    %   numThreeOvnSlots- 
    %                   the number of times in the schedule that exams
    %                   could create this collision type
    whichExams=studentData('whichExams');
    
    numStudents=size(whichExams,1);
    numThreeOvnPerStudent=zeros(numStudents,1);
    numThreeOvnSlots= 0; 
            
    for i=1:size(schedule,2)-1
        for j=3:3:size(schedule,1)
            slot2day1=schedule(j-1,i);
            slot3day1=schedule(j,i);
            slot1day2=schedule(j-2,i+1);
            slot2day2=schedule(j-1,i+1);
            if (slot2day1 ~=0 && slot3day1 ~=0 && slot1day2 ~=0)
                numThreeOvnSlots=numThreeOvnSlots+1;
                numThreeOvnPerStudent=numThreeOvnPerStudent + whichExams(:,slot2day1).*whichExams(:,slot3day1).*whichExams(:,slot1day2);
            end
            if (slot3day1 ~=0 && slot1day2 ~=0 && slot2day2 ~=0)
                numThreeOvnSlots=numThreeOvnSlots+1;
                numThreeOvnPerStudent=numThreeOvnPerStudent + whichExams(:,slot3day1).*whichExams(:,slot1day2).*whichExams(:,slot2day2);
            end
        end
    end
    numThreeOvnCollisions=sum(numThreeOvnPerStudent);

end