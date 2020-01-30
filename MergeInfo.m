% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

classdef MergeInfo
   properties
      id
      mergeHistory
      studentData
      templateData
      score
   end
   methods
      % Constructor. Takes in two optional arguments
      function obj = MergeInfo(sD, tD, merge_pairs)
         obj.mergeHistory = [merge_pairs ];
         obj.studentData = sD;
         obj.templateData = tD;
         obj.score = 0;  
      end
      
      % Operator overloads
      function tf = lt(obj1,obj2)
         if obj1.score < obj2.score
             tf = true;
         else
             tf = false;
         end
      end
      function tf = gt(obj1,obj2)
         if obj1.score > obj2.score
             tf = true;
         else
             tf = false;
         end
      end
      
      function tf = eq(obj1, obj2)
          if obj1.score == obj2.score
             tf = true;
         else
             tf = false;
         end
      end
      
      function tf = ge(obj1, obj2)
          if obj1.score >= obj2.score
             tf = true;
         else
             tf = false;
         end
      end
      
      function tf = le(obj1, obj2)
          if obj1.score <= obj2.score
             tf = true;
         else
             tf = false;
         end
      end
      
   end
end
