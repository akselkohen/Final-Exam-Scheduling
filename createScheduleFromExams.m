% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function schedule= createScheduleFromExams(template,examArrangement)

schedule=zeros(6,7);
n=1;
for i=1:14
    for j=1:3
        week=floor((i-1)/7);
        row=(week*3)+j;
        col=i-(week*7);
        if template(row,col) ~=0
            schedule(row,col)=examArrangement(1,n);
            n=n+1;
        end
    end
end

end