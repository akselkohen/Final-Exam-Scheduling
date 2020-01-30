% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [collisionMatrix,collisionTensor]=studentCollisions(whichExams)
% Calculates the number of students taking pairs or trios of exams 
%based on given registration data
% INPUT:
% whichExams -      an n x m matrix representing n students and m exams to be scheduled. 
%                   If a_ij=1 then student i is taking exam j
% OUTPUT:
% collisionMatrix - an n+1 x n+1 matrix where a_ij represents the number of
%                   students taking the pair of exam i and j
% collisionTensor - an n+1 x n+1 x n+1 tensor where a_ijk represents the
%                   number of students taking the trio of exam i, j, and k

numStudents=size(whichExams,1);
totalNumExams=size(whichExams,2);

% Matrix to count total number of students taking each pair of exams
% There is an extra row and column in the matrix for an empty placeholder
collisionMatrix = zeros(totalNumExams+1,totalNumExams+1);

% Tensor to count total number of students taking each trio of exams
% There is an extra row, column, width in the matrix for an empty placeholder
collisionTensor = zeros(totalNumExams+1,totalNumExams+1,totalNumExams+1);

% Create collision matrix and array by looking at each student
% Find the courses they are taking
% For each pair or trio of courses, update the matrix or tensor
% note: multiple assignment statements due to array and tensor symmetry
for st=1:numStudents 
    student = whichExams(st,:); %look at one student's data
    stExams = find(student==1); %find when the student has exams
    numStExams = size(stExams,2);
    
    for i=1:numStExams %iterate through courses times in a way that checks each pairing/ triple
        for j=(i+1):numStExams
            collisionMatrix(stExams(i),stExams(j)) = 1+collisionMatrix(stExams(i),stExams(j));
            collisionMatrix(stExams(j),stExams(i)) = 1+collisionMatrix(stExams(j),stExams(i));
            for k=(j+1):numStExams
               collisionTensor(stExams(i),stExams(j),stExams(k)) = 1+collisionTensor(stExams(i),stExams(j),stExams(k));
               collisionTensor(stExams(i),stExams(k),stExams(j)) = 1+collisionTensor(stExams(i),stExams(k),stExams(j));
               collisionTensor(stExams(j),stExams(k),stExams(i)) = 1+collisionTensor(stExams(j),stExams(k),stExams(i));
               collisionTensor(stExams(j),stExams(i),stExams(k)) = 1+collisionTensor(stExams(j),stExams(i),stExams(k));
               collisionTensor(stExams(k),stExams(i),stExams(j)) = 1+collisionTensor(stExams(k),stExams(i),stExams(j));
               collisionTensor(stExams(k),stExams(j),stExams(i)) = 1+collisionTensor(stExams(k),stExams(j),stExams(i));
            end
        end
    end
end

end
