%�������������ع���С���ˣ�

function BB=transf(A,P)
%A---output of RBF  A�ǹ��������(�Ѿ��淶��),һ�������ʱ��Ϊ1*1
%P-- sample of input P�ǵ�ǰ���������� 4*1

[u,N]=size(A);  %uΪ��ǰ��������NΪ
[r,N]=size(P);  %rΪ����������ά����NΪ������������Ŀ������Ϊ1��ǰ����ѵ�����ݣ�
for j=1:N
   for i=1:r
      PA((i-1)*u+1:i*u,j)=P(i,j)*A(:,j); %TSKģ�ͣ�
   end 
end
BB=[A;PA];
