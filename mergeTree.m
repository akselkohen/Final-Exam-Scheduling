function [mergeInfoList] = mergeTree(studentData,templateData)

collisionMatrix=studentData('collisionMatrix');
constrExams=templateData('constrExams');

%find the number of nonzero exams to collect pairs from
numNonzeroExams=sum(sum(collisionMatrix,1)>0);

%Create a list of mergable pairs of exams
% Find the zeros in the collision Matrix
mergePairs=[];
for i=1:numNonzeroExams
    for j=i+1:numNonzeroExams
        if (collisionMatrix(i,j)==0) & (sum(ismember([i,j],constrExams))<2)
            mergePairs=[mergePairs ; [i j]];
        end
    end
end

numMergePairs=size(mergePairs,1);
mergeInfoList=[];
%For every pair
for i=1:numMergePairs
    exam1=mergePairs(i,1);
    exam2=mergePairs(i,2);
    % Merge the exams
    [msD,mtD]=mergeExams(exam1,exam2,studentData,templateData);
    % Create a mergeInfo object; it knows its own lineage
    parentHist=mergePairs(i,:);
    parent= MergeInfo(msD,mtD,parentHist);
    childrenList=mergeTree(msD,mtD);
    %tell each child about their lineage
    numChildren=size(childrenList,1);
    for j=1:numChildren
        child=childrenList(j);
        child.mergeHistory = [parentHist; child.mergeHistory];
        childrenList(j)=child;
    end
    mergeInfoList=[mergeInfoList; parent; childrenList];

end %outer for loop

end %function
