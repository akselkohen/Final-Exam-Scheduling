function friScore=friEveScore(schedule, whichExams,friWeight)

if schedule(3,6)~=0
   friday_exam=schedule(3,6);
   no_friev=sum(whichExams(:,friday_exam));
   friScore=no_friev*friWeight;
    
else

friScore=0;
end


end

