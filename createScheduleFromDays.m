% (c) Copyright Johns Hopkins University Department of Applied Mathematics and Statistics 
% (c) This file is a part of the JHU Final Exam Scheduling software suite and is not available for use outside of the Johns Hopkins University.
% (c) The JHU Final Exam Scheduling Software is developed by students in the JHU Scheduling Group
% (C) Questions about this can be addressed to Dr. Donniell Fishkind: def@jhu.edu

% Author(s): Paige Stanley, Anthony Karahalios, Katelyn DeBakey, 
% Aavik Pakrasi, Katie Marks, Avi Mahajan, Aksel Kohen
% Date: April 22, 2018

function [schedule] = createScheduleFromDays(template, chosenTDays, chosenDDays, chosenSDays, constrExams, constrTemplate)
    % create example schedule, just using index nos
%      chosenDDays = [chosenDDays; zeros(1, length(chosenDDays))];

    schedule = zeros(size(template));
%    
%Preallocate triples containing constrained exams
    for i=1:size(chosenTDays,2)
       if sum(ismember(constrExams,chosenTDays(:,i)))>0
           constrTrip=chosenTDays(:,i);
           chosenTDays(:,i)=[-1 ;-1 ;-1];
           whichConstr=ismember(constrExams,constrTrip); %identify which constraint exams are contained in the triplet
           constrIndex = whichConstr==1;
           constrInTrip=constrExams(constrIndex); %collect those contstrained exams
           for j=1:length(constrInTrip) %rearrange triplet to correctly locate constrained exams
             [row , column] =find(constrTemplate==constrInTrip(j));
             if row > 3
                 triprow=row-3;
             else
                 triprow=row;
             end 
             tripIndex=find(constrTrip==constrInTrip(j)); 
             save=constrTrip(triprow);
             constrTrip(tripIndex)=save;
             constrTrip(triprow)=constrInTrip(j);     
           end
           %place triplet in the schedule
            if row <= 3
               schedule(1:3,column)=constrTrip;
            else     
               schedule(4:6,column)=constrTrip;
            end
       end 
    end
    % Collect triplets with no constrained exams
    j=1;
    for i=1:size(chosenTDays,2)
       if chosenTDays(1,i)~=-1
           TDays(:,j)=chosenTDays(:,i);
           j=j+1;
       end
      
    end
   

  %Preallocate doubles containing constrained exams
    for i=1:size(chosenDDays,2)
       if sum(ismember(constrExams,chosenDDays(:,i)))>0
           constrDoub=chosenDDays(:,i);
           chosenDDays(:,i)=[-1 -1];
           whichConstr=ismember(constrExams,constrDoub); %identify which constraint exams are contained in the double
           constrIndex = whichConstr==1;
           constrInDoub=constrExams(constrIndex); %collect those constrained exams
           for j=1:length(constrInDoub) %rearrange double to correctly locate constrained exams
             [row, column] =find(constrTemplate==constrInDoub(j));
             if row > 3
                 doubrow=row-3;
             else
                 doubrow=row;
             end 
             if doubrow ==3
                 doubrow=2;
             end
             doubIndex=find(constrDoub==constrInDoub(j)); 
             save=constrDoub(doubrow);
             constrDoub(doubIndex)=save;
             constrDoub(doubrow)=constrInDoub(j);     
           end
           %place double in the schedule
               if row <=3
                where=find(template(1:3,column)==1);
                schedule(where(1), column) = constrDoub(1);
                schedule(where(2), column) = constrDoub(2);                   
               else
                where=find(template(4:6,column)==1);   
                schedule(3+where(1), column) = constrDoub(1);
                schedule(3+where(2), column) = constrDoub(2);
               end
       end    
    end
    
    %Collect doubles with no constrained exam

    j=1;
    for i=1:size(chosenDDays,2)
       if chosenDDays(1,i)~=-1
           DDays(:,j)=chosenDDays(:,i);
           j=j+1;
       end
      
    end
    %Preallocate singles with constrained exams
    for i=1:length(chosenSDays)
       if sum(ismember(constrExams,chosenSDays(i)))>0
           constrSingle=chosenSDays(i);
           chosenSDays(i)=-1;
           [row, column]=find(constrTemplate==constrSingle);
           %place single in the schedule
               if row <=3
                where=find(template(1:3,column)==1);
                schedule(where, column) = constrSingle;
               else
                where=find(template(4:6,column)==1);   
                schedule(3+where, column) = constrSingle;
               end
       end    
    end
      %Collect singles with no constrained exam
   
    j=1;
    for i=1:size(chosenSDays,2)
       if chosenSDays(1,i)~=-1
           SDays(:,j)=chosenSDays(:,i);
           j=j+1;
       end
      
    end
 

    
%Allocate rest of the triples, doubles and singles
    iT = 1;
    iD = 1;
    iS = 1;
    for i=1:size(template,2)
        for j=1:3:size(template,1)
            if sum(template(j:j+2, i)) == 3 && sum(schedule(j:j+2, i)) == 0
                schedule(j:j+2, i) = TDays(:,iT);
                iT = iT + 1;
            end
            if sum(template(j:j+2, i)) == 2 && sum(schedule(j:j+2, i)) == 0
                where=find(template(j:j+2,i)==1);
                schedule(j-1+where(1), i) = DDays(1,iD);
                schedule(j-1+where(2), i) = DDays(2,iD);
%               schedule(j:j+2, i) = chosenDDays(:,iD);
                iD = iD + 1;
            end
            if sum(template(j:j+2, i)) == 1 && sum(schedule(j:j+2, i)) == 0
              
                where=find(template(j:j+2,i)==1);
                schedule(j-1+where, i) = SDays(1,iS);
%               schedule(j:j+2, i) = chosenSDays(:,iS);
                iS = iS + 1;
            end
        end
        
        
    end

    
end


