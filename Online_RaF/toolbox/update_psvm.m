function [w,EE_inverse,EDE]=update_psvm(w,data,label,EE_inverse,EDE)
data=full(data);
nSam=size(data,1);
E_new=[data,-1*ones(nSam,1)];
De=ones(nSam,1);
index= label==-1;
De(index)=-1;
EDE_new=E_new'*De;
%EE_new=E_new'*E_new;
EE_inverse_temp=EE_inverse-EE_inverse*E_new'*pinv(speye(nSam)+E_new*EE_inverse*E_new')*E_new*EE_inverse;
 %EE_inverse_temp=EE_inverse-EE_inverse*E_new'*((speye(nSam)+E_new*EE_inverse*E_new')\E_new)*EE_inverse;

 % M = M - M * H' * (eye(Block) + H * M * H')^(-1) * H * M; 
 % beta = beta + M * H' * (Tn - H * beta);

w_temp=w+EE_inverse_temp*E_new'*(De-E_new*w);
EE_inverse=EE_inverse_temp;
w=w_temp;

EDE_temp=EDE+EDE_new;
EDE=EDE_temp;
end