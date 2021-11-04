%����RBF��FNN��α���ߣ�Mackey-Glass,�ݶ��½�������һ��һ��������Χ��ѭ��
%���ߣ��ܺ��
%�ص㣺������ҵ��ѧ��ѧ¥
%���ڣ�2016.4.19

%% ���
clc;
clear all;
close all;

%% ��ʼ��Mackey-Glass����
%ѵ������
x=ones(1,4000); x(1)=1.2;
for t=18:4017
    x(t+1)=0.9*x(t)+0.2*x(t-17)/(1+x(t-17).^10);
end
x1=x(136:635); x2=x(130:629);
x3=x(124:623); x4=x(118:617);
TrainSamInN=[x1;x2;x3;x4]; 
TrainSamOutN=x(142:641);
[InDim,TrainSamNum]=size(TrainSamInN); %InDim����ά��4��TrainSamNumѵ��������500
OutDim=size(TrainSamOutN,1); % OutDim���ά��Ϊ1
% ��������
x5=x(636:1135); x6=x(630:1129);
x7=x(624:1123); x8=x(618:1117);
TestSamInN=[x5;x6;x7;x8];
TestSamOutN=x(642:1141);
TestSamNum=size(TestSamInN,2); %TestSamNum����������500

%��һ��
[TrainSamIn,inputps]=mapminmax(TrainSamInN,0,1);
[TrainSamOut,outputps]=mapminmax(TrainSamOutN,0,1);
TestSamIn=mapminmax('apply',TestSamInN,inputps);

%% ��������
RuleNum=10; %������=10
MaxEpoch=500; %���ѵ��������300��
E0=0.001; %Ŀ�����
lr=0.01; %ѧϰ��,ȡ0.01��1000������0.1��300����

%�������һ�����ġ���ȡ�Ȩֵ����һ����ȡrand
Center=rand(InDim,RuleNum); %��������������
Width=ones(InDim,RuleNum); %������������,ȡones����Ҫ
W=rand(RuleNum,OutDim); %������������֮��Ȩֵ   

% load Center_0 
% load Width_0 
% load W_0 
% Center=Center_0;
% Width=Width_0;
% W=W_0;
%%  ��ģ
tic
% �ظ�ѵ��2000��,MaxEpoch
for epoch=1:MaxEpoch
    epoch  
%     epoch=1

%% ��ȡѵ������TrainSamIn��TrainSamNum
    for k=1:TrainSamNum
%       k=1 
        SamIn=TrainSamIn(:,k);          
        % ���������㣬ģ����
        for i=1:InDim
            for j=1:RuleNum
                MemFunUnitOut(i,j)=exp(-(SamIn(i)-Center(i,j))^2/Width(i,j)^2);
            end
        end     
        % �����
        RuleUnitOut=prod(MemFunUnitOut,1); %��������
        % ��һ����
        RuleUnitOutSum=sum(RuleUnitOut); %����������� 
        NormValue=RuleUnitOut./RuleUnitOutSum; %��һ�������������֯����NormValue
        % �����
        NetOut=NormValue*W; %������������������� 
        Error(k)=TrainSamOut(:,k)-NetOut;%���=�������-����ʵ�����  e=yd-y
    
        % �ݶ�     
        % Ȩֵ������ 
        AmendW=0*W;
        for j=1:RuleNum
             AmendW(j)=-Error(k)*NormValue(j);   
        end
        %����������
        AmendCenter=0*Center;
        for i=1:InDim  
            for j=1:RuleNum     
                AmendCenter(i,j)=-Error(k)*W(j)*(RuleUnitOutSum-RuleUnitOut(j))*RuleUnitOut(j)*2*(SamIn(i)-Center(i,j))/(Width(i,j)^2*RuleUnitOutSum^2);
            end
        end
        % ���������
        AmendWidth=0*Width;
        for i=1:InDim 
            for j=1:RuleNum      
                AmendWidth(i,j)=-Error(k)*W(j)*(RuleUnitOutSum-RuleUnitOut(j))*RuleUnitOut(j)*2*(SamIn(i)-Center(i,j))^2/(Width(i,j)^3*RuleUnitOutSum^2);
            end
        end
       
        % �������ġ���ȡ�Ȩֵ
        W=W-lr*AmendW; 
        Center=Center-lr*AmendCenter;
        Width=Width-lr*AmendWidth;

    end 
   
   % ѵ��RMSE
   RMSE(epoch)=sqrt(sum(Error.^2)/TrainSamNum); %TrainSamNum��������
   
   if RMSE(epoch)<E0,break,end
   
end
TrainTime=toc
%% ѵ������Ԥ��
for k=1:TrainSamNum
    SamIn=TrainSamIn(:,k);
    % ���������㣬ģ����
    for i=1:InDim
        for j=1:RuleNum
            TrainMemFunUnitOut(i,j)=exp(-((SamIn(i)-Center(i,j))^2)/(Width(i,j)^2));
        end
    end
    % �����
    TrainRuleUnitOut=prod(TrainMemFunUnitOut); %��������
    % �����
    TrainRuleUnitOutSum=sum(TrainRuleUnitOut); %�����������
    TrainRuleValue=TrainRuleUnitOut./TrainRuleUnitOutSum; %������һ�����������֯ʱRuleNum�Ǳ仯��
    TrainNetOut(k)=TrainRuleValue*W; %�������������������
end
TrainNetOutN=mapminmax('reverse',TrainNetOut,outputps);    
%% ��������Ԥ��
   for k=1:TestSamNum
       SamIn=TestSamIn(:,k);
        % ���������㣬ģ����
        for i=1:InDim
            for j=1:RuleNum
                TestMemFunUnitOut(i,j)=exp(-((SamIn(i)-Center(i,j))^2)/(Width(i,j)^2));
            end
        end     
        % �����
        TestRuleUnitOut=prod(TestMemFunUnitOut); %��������          
        % �����
        TestRuleUnitOutSum=sum(TestRuleUnitOut); %�����������
        TestRuleValue=TestRuleUnitOut./TestRuleUnitOutSum; %������һ�����������֯ʱRuleNum�Ǳ仯��
        TestNetOut(k)=TestRuleValue*W; %�������������������
   end
TestNetOutN=mapminmax('reverse',TestNetOut,outputps);   
%% ������Լ�RMSE��APE������
TestError=TestSamOutN-TestNetOutN;
TestRMSE=sqrt(sum(TestError.^2)/TestSamNum);
TestAPE=sum(abs(TestError)./abs(TestSamOutN))/TestSamNum;
TestAccuracy=sum(1-abs(TestError./TestSamOutN))/TestSamNum;
TestRMSE
TestAPE
TestAccuracy

%% ��������
%ѵ���������
figure(1)
plot(RMSE,'k-','LineWidth',2)
xlabel('ѵ������','fontsize',9)
ylabel('RMSEֵ','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�
% xlim([0 100])
%ѵ�������ͼ
figure(2)
plot(TrainSamOutN,'k-','LineWidth',2)
hold on
plot(TrainNetOutN,'r--','LineWidth',2)
h=legend('Real values','Forecasting output');
set(h,'Fontsize',9);
xlabel('ѵ������','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.14 .16 .80 .80]);  %���� XLABLE��YLABLE���ᱻ�е�
%���Խ����ͼ
figure(3)
k=501:1000;
plot(k,TestSamOutN,'k-','LineWidth',2)
hold on
plot(k,TestNetOutN,'r--','LineWidth',2)
h=legend('Real values','Forecasting output');
set(h,'Fontsize',9);
xlabel('��������','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.14 .16 .80 .80]);  %���� XLABLE��YLABLE���ᱻ�е�
%�����������
figure(4)
k=501:1000;
plot(k,TestError,'k-','LineWidth',2)
xlabel('��������','fontsize',9)
ylabel('Ԥ�����','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.17 .16 .79 .80]);  %���� XLABLE��YLABLE���ᱻ�е�

%% ��������
TrainRMSE_GD=RMSE;
save TrainRMSE_GD TrainRMSE_GD
