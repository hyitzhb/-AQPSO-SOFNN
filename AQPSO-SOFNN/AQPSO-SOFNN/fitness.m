function [fit,Weights]=fitness(pop,RuleNum,TrainSamIn,TrainSamOut)
% ����
[InDim,TrainSamNum]=size(TrainSamIn); %����ά����ѵ��������
OutDim=size(TrainSamOut,1);   %���ά��

Center=[];Width=[];NormValueMatrix=[];RegressorMatrix=[];Weights=[];

Center=pop(1:InDim,1:RuleNum); %ǰ4��Ԫ��������
Width=pop(InDim+1:2*InDim,1:RuleNum);        %��4��Ԫ���ǿ��

% ���ȼ��㴰���������Ĺ���������NormValueMatrix
NormValueMatrix=GetMeNormValue(TrainSamIn,Center,Width);
% ���ݹ�������NormValue���õ��ع�������RegressorMatrix
RegressorMatrix=GetMeRegressorMatrix(NormValueMatrix,TrainSamIn); %RegressorMatrix��M��N�У�M=RuleNum*(InDim+1)��N�Ǵ�����������


% ���ݻع�������RegressorMatrix���õ�Hermitian����H,�������(���Ȩֵ)Weights
Weights=DeriveWeights(RegressorMatrix,TrainSamOut);   %10��ģ������������50��Ȩ��ϵ��
NetOut=Weights*RegressorMatrix;
% ����ѵ��������RMSE
RMSE=sqrt(sumsqr(TrainSamOut-NetOut)/(OutDim*TrainSamNum)); %ѵ��������RMSE

fit=RMSE*(1+0.9*RuleNum); %��������������Ӧ��ֵ
end