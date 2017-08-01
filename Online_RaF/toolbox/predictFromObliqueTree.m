function classLabelIds = predictFromObliqueTree(tree,X)
%predictFromObliqueTree predicts class using trained tree
%
% [classLabelIds, classLabels, countsLeaf] = predictFromObliqueTree(tree,X)
%
% Inputs:   tree = output strcut from growTree
%              X = processed input features
% Outputs:  classLabelIds = Vector of numeric predictions corresponding to
%                         the class label ids.  Note this is not
%                         necessarily the class itself, e.g. if the classes
%                         are the digits 0 to 9, then classLabelId==1 is
%                         digit 0.
%           countsLeaf  = Training counts at the assigned leaf.
%
% 14/06/15

    if tree.bLeaf
        classLabelIds = tree.labelClassId*ones(size(X,1),1);
       
    else
       
        
        bLessChild = (X(:,tree.iIn)*tree.w)<=tree.gamma;
        
        classLabelIds = NaN(size(X,1),1);
      
        
        if any(bLessChild)
           
                classLabelIds(bLessChild) = predictFromObliqueTree(tree.lessthanChild,X(bLessChild,:));
            
        end
        if any(~bLessChild)
            
                classLabelIds(~bLessChild) = predictFromObliqueTree(tree.greaterthanChild,X(~bLessChild,:));
            
        end
    end
end
