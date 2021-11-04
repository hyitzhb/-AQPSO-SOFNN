%����D-FNN����̬ģ�������磬��������֯������½��ʣ���С����
%Mackey-Glass����
%�ܺ��

%% ���
clc;
clear all;
close all;
%% ����Mackey-Glass����
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
% [TrainSamIn,inputps]=mapminmax(TrainSamInN,0,1);   %TrainSamInΪѵ���������룬4*500
% [TrainSamOut,outputps]=mapminmax(TrainSamOutN,0,1);%TrainSamOutΪѵ���������,1*500
% TestSamIn=mapminmax('apply',TestSamInN,inputps);   %TestSamInΪ������������,4*500

% �����һ��
TrainSamIn=TrainSamInN;
TrainSamOut=TrainSamOutN;
TestSamIn=TestSamInN;
%% ������ֵ
%kdmax����kd��������ֵ��kdmin����kd�������Сֵ��gama˥������������kd��
%emax����������emin�������С��beta��������������
%width0��һ��ģ������Ŀ�ȣ�ko�ص����ӣ�kw��ȵ���������
%kerr����½��ʷ��޼������õ�Ԥ����ֵ
kdmax=2;            kdmin=0.25;             gama=0.98;
emax=1.1;           emin=0.02;              beta=0.95;
width0=1;           ko=1.2;                 kw=0.98;
kerr=0.00015;

%% Ԥ�������
TrainSamIn_All=[]; %���ڴ������ѵ������������
TrainSamOut_All=[];%���ڴ������ѵ�����������
Center_All=[];     %���ڴ�����е�ģ�����������

tic
%% ��̬����DFNN
%���ڵ�һ������
TrainSamIn_All=TrainSamIn(:,1);
TrainSamOut_All=TrainSamOut(:,1);

%���ݵ�һ����������DFNN�ĵ�һ��ģ������
Center_All=TrainSamIn(:,1);%��һ��������Ϊ���ģ�
Center=Center_All'; %Center����������������
Width(1)=width0; %���ΪԤ��ֵ������һ�������������ͬģ��������һ�����
RuleNum_his(1)=1; %RuleNum���ڼ�¼ѵ�����̵�ģ�������������ڵ�һ��������ģ��������=1

%�����һ��������������
RuleUnitOut=RBF(dist(Center,TrainSamIn_All),1./Width'); %RuleUnitOutΪ�����������϶�Ϊ1����Ϊ����Ϊ�����㣬��˹�������Ϊ1
%dist�����Ǽ���Center��TrainSamIn_All֮���ŷʽ����
%Center������Ӧ��TrainSamIn_All��������ȣ�Center��1*4��All_TrainSamIn��4*1
%ŷʽ������mά�ռ���������֮�����ʵ���룬d=sqrt((x1-x2)^2+(y1-y2)^2)
%ע�⣬��RBF�Ѿ��������Ӳ���������ȥ(dist����)
NormValue=RuleUnitOut/sum(RuleUnitOut);%NormValueΪ�淶���������NormValue=1
NormValue_new=[NormValue TrainSamIn(:,1)'];  %NormValue_newΪ1*5???
W=TrainSamOut_All/NormValue_new'; %��α�������Ȩֵ(���������Ȩֵ)�����ڵ�һ�����ݣ�����ֻ��һ�����򣬶���TSKģ�͡�
% WΪ���Ȩֵ��WΪ1*(4+1)
NetOut=W*NormValue_new'; %NetOutΪ������������ڵ�1��������ֻ��1��ֵ
Error(1)=TrainSamOut(:,1)-NetOut; %���=������ʵ���-����Ԥ�����
e_norm(1)=sqrt(sum(Error(1).*Error(1))/OutDim); %��ȡ��ǰ���������,����ָ��ģ������Ĳ���;���ڵ���������e_norm(i)=abs(Error)
RMSE(1)=sqrt(sumsqr(TrainSamOut_All-NetOut)/(OutDim*1)); %sumsqr��ƽ���ͺ�������һ��������RMSE�϶�Ϊ0

%% �ӵڶ���������ʼ��˳��ѧϰ
for i=2:TrainSamNum
    i
    TrainSamIn_All=[TrainSamIn_All TrainSamIn(:,i)];%�����洢ѵ��������������,4*i     %TrainSamIn(:,i) ��i������������,4*1
    TrainSamOut_All=[TrainSamOut_All TrainSamOut(:,i)];%�����洢ѵ���������������1*i %TrainSamOut(:,i) ��i�����������,1*1
    Num_Current=size(TrainSamOut_All,2);  %Num_CurrentΪ��ǰ�������ݸ���������=i
    RuleNum=size(Center,1); %center��Զ��4�У���ʾ���������4ά��RuleNum��ʾ��ǰ���ĵ���Ŀ
    dd=dist(Center,TrainSamIn(:,i)); %���㵱ǰ��i������������������ģ����������֮��ľ���
    [d_min,ind]=min(dd); %�ҳ���С�ľ���d_min��ind�Ƕ�Ӧ������
    kd=max(kdmax*gama.^(i-1),kdmin);%��kd���ж�̬����
    
    %�ڵ�ǰ����ṹ�£������i��������Ԥ�����
    RuleUnitOut=RBF(dist(Center,TrainSamIn(:,i)),1./Width'); %RuleUnitOut��RBF������
    NormValue=RuleUnitOut/sum(RuleUnitOut); %ai�ǹ���������(�ѹ淶��)����ֻ��һ������ʱ���淶����Ϊai=1
    NormValue_new=transf(NormValue,TrainSamIn(:,i));%ִ��TSKģ�ͣ�һ������ai1��5��ֵ��
    NetOut=W*NormValue_new; %�������
    Error(i)=TrainSamOut(:,i)-NetOut; %���=������ʵ���-����Ԥ�����
    e_norm(i)=sqrt(sum(Error(i).*Error(i))/OutDim); %��ȡ��ǰ���������,����ָ��ģ������Ĳ���;���ڵ���������e_norm(i)=abs(Error)
    ke=max(emax*beta.^(i-1),emin); %��̬����ke
    
    %% ģ����������֯��ǰ���ͺ���������������������
    
    %% ��һ�����,��ʱDFNN�нϺõķ�����������ȫ�������ɹ۲����ݣ�����Ҫ��ʲô���������º������
    %e_norm(i)<=ke�������ϵͳ���нϺõķ�������
    %d_min<=kd�������ϵͳ��ĳЩ��Ԫ�ܹ���������������������FNN�ܹ���������۲�����
    if e_norm(i)<=ke && d_min<=kd
        RuleUnitOut=RBF(dist(Center,TrainSamIn_All),1./Width');            %��������
        NormValue=RuleUnitOut./(ones(RuleNum,1)*sum(RuleUnitOut)); %�淶�����
        NormValue_new=transf(NormValue,TrainSamIn_All);
        W=TrainSamOut_All/NormValue_new; %�������Ȩֵ��8*��1+4��=40������
        NetOut=W*NormValue_new;
        RMSE(i)=sqrt(sumsqr(TrainSamOut_All-NetOut)/(OutDim*i)); %���������ǵ�һ��������ĿǰΪֹϵͳ������������RMSE
        RuleNum_his(i)=RuleNum; %��ǰģ��������
    end
    
    %% �ڶ����������������DFNN���нϺõķ���������ֻ�н��������Ҫ����
    %e_norm(i)<=ke�������ϵͳ���нϺõķ�������
    %d_min>kd�������ϵͳ�������걸�ԣ�Ҫ��������һ��ģ������������ɣ�
    %��������£�ֻ��Ҫ�������������
    %�޸�Ϊ���ڴ�����£�������С������Ǹ���Ԫ��Ӧ�����������Ŀ��Ӧ�ñ��Ŵ�
    if e_norm(i)<=ke && d_min>kd    
        RuleUnitOut=RBF(dist(Center,TrainSamIn_All),1./Width');
        NormValue=RuleUnitOut./(ones(RuleNum,1)*sum(RuleUnitOut));
        NormValue_new=transf(NormValue,TrainSamIn_All);
        W=TrainSamOut_All/NormValue_new;
        NetOut=W*NormValue_new;
        RMSE(i)=sqrt(sumsqr(TrainSamOut_All-NetOut)/(OutDim*i)); %���������
        RuleNum_his(i)=RuleNum; %��ǰģ��������
    end
    
    %% ���������,����RBF��Ԫ�ķ������������Ǻܺã���Ҫ����RBF�ڵ�Ŀ�Ⱥͽ������
    %e_norm(i)>ke�������ϵͳ���������ϲ�
    %d_min<=kd����FNN�ܹ���������۲�����
    if e_norm(i)>ke && d_min<=kd
        Width(ind)=kw*Width(ind); %ind����ӽ���ǰ������ģ�����򣬶����Ƚ��е���
        RuleUnitOut=RBF(dist(Center,TrainSamIn_All),1./Width');
        NormValue=RuleUnitOut./(ones(RuleNum,1)*sum(RuleUnitOut));
        NormValue_new=transf(NormValue,TrainSamIn_All);
        W=TrainSamOut_All/NormValue_new;
        NetOut=W*NormValue_new;
        RMSE(i)=sqrt(sumsqr(TrainSamOut_All-NetOut)/(OutDim*i));
        RuleNum_his(i)=RuleNum; %��ǰģ��������
    end
    
    %% ��������������󣬵�ǰ���������ĵ���С���볬���˿����ɱ߽����Ч�뾶����Ҫ����һ���µ�ģ������
    %e_norm(i)>ke�������ϵͳ���������ϲ�
    %d_min>kd����FNN���ܹ���������۲�����
    if e_norm(i)>ke && d_min>kd
        Center_All=[Center_All TrainSamIn(:,i)]; %����һ��ģ���������ľ��ǵ�i������������
        Width_new=ko*d_min; %����RBF��Ԫ�Ŀ�ȣ�������ص�����ko*d_min
        Width=[Width Width_new];
        Center=Center_All';
        RuleNum=size(Center,1); %RuleNum_CurrentΪ��ǰRBF��Ԫ������������
        %������ģ������󣬼���RBF��Ԫ�����
        RuleUnitOut=RBF(dist(Center,TrainSamIn_All),1./Width'); %RBF��Ԫ����������˲���
        NormValue=RuleUnitOut./(ones(RuleNum,1)*sum(RuleUnitOut));%��һ��
        NormValue_new=transf(NormValue,TrainSamIn_All);%A2Ӧ���������������H
        
        % ����½����޼�,��������N���ڵ���u*(r+1)ʱ���ż����������½��ʵ��޼�����������QR�ֽ��޷�ִ��
        if RuleNum*(1+InDim)<=Num_Current  %RuleNum�ǵ�ǰģ����������InDim������ά����Num_CurrentΪ��ǰ��������
            %��������½���
            tT=TrainSamOut_All';
            PAT=NormValue_new';
            [WW,AW]=orthogonalize(PAT); %��������������������������
            SSW=sum(WW.*WW)';SStT=sum(tT.*tT)';
            err=((WW'*tT)'.^2)./(SStT*SSW');
            errT=err';
            err1=zeros(RuleNum,OutDim*(InDim+1));
            err1(:)=errT;
            err21=err1';
            err22=sum(err21.*err21)/(OutDim*(InDim+1));
            err23=sqrt(err22);
            No=find(err23<kerr);
            if ~isempty(No) %��������½����޼�ģ������
                Center_All(:,No)=[];Center(No,:)=[]; %�޼���ģ������
                Width(:,No)=[];err21(:,No)=[];
                [uu,vv]=size(Center);
                AA=RBF(dist(Center,TrainSamIn_All),1./Width');
                AA0=sum(AA);
                AA1=AA./(ones(uu,1)*AA0);
                AA2=transf(AA1,TrainSamIn_All);
                W=TrainSamOut_All/AA2;
                outAA2=W*AA2;
                sse0=sumsqr(TrainSamOut_All-outAA2)/(i*OutDim);
                RMSE(i)=sqrt(sse0);
                RuleNum_his(i)=uu;
                w2T=W';ww2=zeros(uu,OutDim*(InDim+1));
                ww2(:)=w2T;
                w21=ww2';
            else  %����Ҫ�޼��Ļ�����ִ������
                W=TrainSamOut_All/NormValue_new;
                outA2=W*NormValue_new;
                sse0=sumsqr(TrainSamOut_All-outA2)/(OutDim*i);
                RMSE(i)=sqrt(sse0);
                RuleNum_his(i)=RuleNum;
                w2T=W';ww2=zeros(RuleNum,OutDim*(InDim+1));
                ww2(:)=w2T;
                w21=ww2';
            end
        else %����u*(r+1)>N
            W=TrainSamOut_All/NormValue_new;
            outA2=W*NormValue_new;
            sse0=sumsqr(TrainSamOut_All-outA2)/(OutDim*i);
            RMSE(i)=sqrt(sse0);
            RuleNum_his(i)=RuleNum;
            w2T=W';ww2=zeros(RuleNum,OutDim*(InDim+1));
            ww2(:)=w2T;
            w21=ww2';
        end  % if u*(r+1)<=N
        
    end
    
   
end
TrainTime=toc

%% ѵ����Ԥ��
RuleUnitOut=RBF(dist(Center,TrainSamIn),1./Width');
NormValue=RuleUnitOut./(ones(RuleNum,1)*sum(RuleUnitOut));
NormValue_new=transf(NormValue,TrainSamIn);
TrainNetOut=W*NormValue_new;
% TrainNetOutN=mapminmax('reverse',TrainNetOut,outputps); %ѵ�����������һ��   
TrainNetOutN=TrainNetOut; %�����һ��
%% ����ѵ����RMSE��APE������
TrainError=TrainSamOutN-TrainNetOutN;
TrainRMSE=sqrt(sum(TrainError.^2)/TrainSamNum);
TrainAPE=sum(abs(TrainError)./abs(TrainSamOutN))/TrainSamNum;
TrainAccuracy=sum(1-abs(TrainError./TrainSamOutN))/TrainSamNum;
TrainRMSE
TrainAPE
TrainAccuracy

%% ���Լ�Ԥ��
RuleUnitOut=RBF(dist(Center,TestSamIn),1./Width');
NormValue=RuleUnitOut./(ones(RuleNum,1)*sum(RuleUnitOut));
NormValue_new=transf(NormValue,TestSamIn);
TestNetOut=W*NormValue_new;
% TestNetOutN=mapminmax('reverse',TestNetOut,outputps);  %���Լ��������һ��  
TestNetOutN=TestNetOut; %�����һ��
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
figure;
plot(RuleNum_his,'k-','LineWidth',2);
title('Fuzzy rule generation');
xlabel('Input sample patterns');
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�
ylim([min(RuleNum_his)-1 max(RuleNum_his)+1]);

figure;
plot(Error,'k');
xlabel('Training samples','fontsize',9)
ylabel('Actual output error','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�
ylim([-0.1 0.1])

figure;
plot(RMSE,'k-','LineWidth',2)
xlabel('ѵ������','fontsize',9)
ylabel('RMSEֵ','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�
% xlim([0 100])
%ѵ�������ͼ

figure;
plot(TrainSamOutN,'k-','LineWidth',2)
hold on
plot(TrainNetOutN,'r--','LineWidth',2)
h=legend('Real values','Forecasting output');
set(h,'Fontsize',9);
xlabel('ѵ������','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.14 .16 .80 .80]);  %���� XLABLE��YLABLE���ᱻ�е�

%���Խ����ͼ
figure;
k=TrainSamNum+1:TrainSamNum+TestSamNum;
plot(k,TestSamOutN,'k-','LineWidth',2)
hold on
plot(k,TestNetOutN,'r--','LineWidth',2)
h=legend('Real values','Forecasting output');
set(h,'Fontsize',9);
xlabel('��������','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.14 .16 .80 .80]);  %���� XLABLE��YLABLE���ᱻ�е�

%�����������
figure;
k=TrainSamNum+1:TrainSamNum+TestSamNum;
plot(k,TestError,'k-','LineWidth',2)
xlabel('��������','fontsize',9)
ylabel('Ԥ�����','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.17 .16 .79 .80]);  %���� XLABLE��YLABLE���ᱻ�е�
