function RegressorMatrix=GetMeRegressorMatrix(NormValue,SamIn)
% ����ӳ�������������һ�������Ա����ģ������Ľ������

%RuleUnitOut---RBF��Ԫ�������������Ԫ�����
%SamIn-- TrainSamIn(:,k)����ѵ���������룬�����ǵ���������Ҳ�����ǵ�ĿǰΪֹ��ѵ��������
%���ڵ���������˵���м���ģ����������RuleUnitOut��ΪRuleNum*1
%���ڶ��������˵���м���ģ����������RuleUnitOut��ΪRuleNum*SamNum

[RuleNum,SamNum]=size(NormValue); %RuleNumΪ����������RuleUnitOut���������������
[InDim,SamNum]=size(SamIn); %SamNumΪ����������RuleUnitOut����������������

for j=1:SamNum
    for i=1:InDim
        PA((i-1)*RuleNum+1 : i*RuleNum,j )=SamIn(i,j)*NormValue(:,j);
    end
end

RegressorMatrix=[NormValue;PA];
