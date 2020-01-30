% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [collisionScore, collisionCounts, collisionCountsByStudent] = collisionScores(schedule,studentData,scoringOptions)
    collisionTypes = scoringOptions('collisionTypes');
    whichCollisionScores = scoringOptions('whichCollisionScores');
    collisionWeights=scoringOptions('collisionWeights');

    numCollisionTypes=length(collisionTypes);
    collisionCounts = zeros(1,numCollisionTypes);
    whichExams=studentData('whichExams');
    numStudents=size(whichExams,1);
    collisionCountsByStudent=zeros(numStudents,numCollisionTypes);
    collisionScore= 0;
    for i = 1:numCollisionTypes
        if whichCollisionScores(1,i) == 1
            FunctionName = str2func(collisionTypes(i)+"Score");
            [collisionCounts(i),collisionCountsByStudent(:,i),~] = FunctionName(schedule, studentData);
            collisionScore= collisionScore+ collisionWeights(i)*collisionCounts(i);
        end
    end
end