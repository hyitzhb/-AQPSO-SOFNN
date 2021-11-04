function NormValue=GetMeNormValue(TrainSamIn,Center,Width)
% ���ܣ������������
% ���룺
%     TrainSamIn_All��ѵ���������룬 InDim*SamNum
%     Center: ���ģ�InDim*RuleNum
%     Width: ��ȣ�InDim*RuleNum
%     Width_Left: ���ȣ�InDim*RuleNum
%     Width_Right: �ҿ�ȣ�InDim*RuleNum
% �����
% RuleUnitOut: RuleNum��SamNum��

[InDim,SamNum]=size(TrainSamIn); %InDim������ά����SamNum����������
[InDim,RuleNum]=size(Center); %InDim������ά����RuleNum��ģ��������

for k=1:SamNum   %���ٸ�������ѭ�����ٴ�
    %     k=1 %������
    SamIn=TrainSamIn(:,k);
    
    %�������������
    for i=1:InDim
        for j=1:RuleNum

            MemFunUnitOut(i,j)=exp(-(SamIn(i)-Center(i,j))^2/Width(i,j)^2);
        end
    end
    % �����
    RuleUnitOut(:,k)=prod(MemFunUnitOut,1); %��������,��������������ڵ����������������Ӧ������
   
    % ��һ����
    RuleUnitOutSum(k)=sum(RuleUnitOut(:,k)); %�����������
    NormValue(:,k)=RuleUnitOut(:,k)./RuleUnitOutSum(k); %��һ�������������֯����NormValue
end




