% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [] = printFormattedSchedule(schedule)

daysOfWeek=["Su","M","T","W","Th","F","Sa"];

if class(schedule)=='double'
    subFormNum='%-5d ';
    subFormString='%-5s ';
    formNum='';
    formString='';
    for j=1:size(schedule,2)
        formNum=strcat(formNum,subFormNum);
        formString=strcat(formString,subFormString);
    end
    
    for i=1:size(schedule,1)
        if mod (i,3)==1
            disp(sprintf(formString,daysOfWeek))
        end
        disp(sprintf(formNum,schedule(i,:)))
    end
    disp(' ')
    
elseif class(schedule)=='string'
    subFormString='%-12s |';
    formString='|';
    for j=1:size(schedule,2)
        formString=strcat(formString,subFormString);
    end
    
    for i=1:size(schedule,1)
        if mod (i,3)==1
            disp(sprintf(formString,daysOfWeek))
        end
        disp(sprintf(formString,schedule(i,:)))
    end
    disp(' ')
else
    error('This function cannot print schedules of class %s',class(schedule))
end

end
