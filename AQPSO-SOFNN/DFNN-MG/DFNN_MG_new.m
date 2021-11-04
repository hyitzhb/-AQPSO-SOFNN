% DFNN ��̬ģ��������
% ����Mackey-Glass Time-series prediction
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
% ��������
x5=x(636:1135); x6=x(630:1129);
x7=x(624:1123); x8=x(618:1117);
TestSamInN=[x5;x6;x7;x8];
TestSamOutN=x(642:1141);

%��һ��
[TrainSamIn,inputps]=mapminmax(TrainSamInN,0,1);
[TrainSamOut,outputps]=mapminmax(TrainSamOutN,0,1);
TestSamIn=mapminmax('apply',TestSamInN,inputps);

%ά����������������
[InDim,TrainSamNum]=size(TrainSamIn); %InDimΪ����ά��4��TrainSamNumΪѵ��������500
OutDim=size(TrainSamOut,1); % OutDimΪ���ά��Ϊ1
TestSamNum=size(TestSamIn,2); %TestSamNumΪ����������500

%% ������ֵ
%kdmax����kd��������ֵ��kdmin����kd�������Сֵ��gama˥������������kd��
%emax����������emin�������С��beta��������������
%width0��һ��ģ������Ŀ�ȣ�k�ص����ӣ�kw ��ȵ���������
%kerr����½��ʷ��޼������õ�Ԥ����ֵ
kdmax=2;            kdmin=0.25;             gama=0.98; 
emax=1.1;           emin=0.02;              beta=0.95;           
width0=1;           k=1.2;                  kw=1.1; 
kerr=0.00025;

All_TrainSamIn=[]; %���ڴ������ѵ������������
All_TrainSamOut=[];%���ڴ������ѵ�����������
All_Center=[];     %���ڴ�����е�ģ�����������

%% ѵ��DFNN
%����һ����������ʱ
All_TrainSamIn=TrainSamIn(:,1); 
All_TrainSamOut=TrainSamOut(:,1);

%���ݵ�һ����������DFNN�ĵ�һ��ģ������
All_Center=TrainSamIn(:,1);%��һ��������Ϊ���ģ�
Center=All_Center'; %Center����������������
Width(1)=width0; %���ΪԤ��ֵ������һ�������������ͬģ��������һ�����
RuleNum(1)=1; %RuleNum���ڴ洢ѵ�����̵�ģ�������������ڵ�һ��������ģ��������=1

%�����һ��������������
a0=RBF(dist(Center,All_TrainSamIn),1./Width'); %����������������϶�Ϊ1����Ϊ����Ϊ�����㣬��˹�������Ϊ1
%dist�����Ǽ���Center��All_TrainSamIn֮���ŷʽ����
%Center������Ӧ��All_TrainSamIn��������ȣ�Center��1*4��All_TrainSamIn��4*1
%ŷʽ������mά�ռ���������֮�����ʵ���룬d=sqrt((x1-x2)^2+(y1-y2)^2)
%ע�⣬��RBF�Ѿ��������Ӳ���������ȥ(dist����)
a0=a0/sum(a0);%�淶����a0����Ϊ1
a01=[a0 TrainSamIn(:,1)']; 
W=All_TrainSamOut/a01'; %��α�������Ȩֵ�����ڵ�һ�����ݣ�����ֻ��һ�����򣬶���TSKģ�ͣ�WΪ1*(4+1)
NetOut=W*a01'; %�������
RMSE(1)=sqrt(sumsqr(All_TrainSamOut-NetOut)/OutDim); %sumsqr��ƽ���ͺ�������һ��������RMSE�϶�Ϊ0

%����2����������������ʱ
for i=2:TrainSamNum
    i
%     pause(0.01)
%     i=2
    Current_TrainSamIn=TrainSamIn(:,i);  %��i������������
    Current_TrainSamOut=TrainSamOut(:,i);%��i�����������
    All_TrainSamIn=[All_TrainSamIn Current_TrainSamIn];%�����洢����������������
    All_TrainSamOut=[All_TrainSamOut Current_TrainSamOut];%�����洢�����������������1*N
    N=size(All_TrainSamOut,2); %r=1,����rδ�õ���NΪ��ǰ��������
    [s,r]=size(Center); %center��Զ��4�У���ʾ���������4ά��r=4��s����������ʾ��ǰ���ĵ���Ŀ
    dd=dist(Center,Current_TrainSamIn); %���㵱ǰ��i������������������ģ����������֮��ľ���
    [d_min,ind]=min(dd); %�ҳ���С�ľ���d_min��ind�Ƕ�Ӧ������
    kd=max(kdmax*gama.^(i-1),kdmin);%��kd���ж�̬����
    
    %�ڵ�ǰ����ṹ�£������i��������Ԥ�����
    ai=RBF(dist(Center,Current_TrainSamIn),1./Width'); %ai��RBF������
    ai=ai/sum(ai); %ai�ǹ���������(�ѹ淶��)����ֻ��һ������ʱ���淶����Ϊai=1
    ai1=transf(ai,Current_TrainSamIn);%ִ��TSKģ�ͣ�һ������ai1��5��ֵ��
    NetOut=W*ai1; %�������
    errout=Current_TrainSamOut-NetOut; %���=������ʵ���-����Ԥ�����
    e(i)=sqrt(sum(errout.*errout)/OutDim); %��ȡ��ǰ���������,����ָ��ģ������Ĳ���;���ڵ���������e(i)=abs(errout)
    ke=max(emax*beta.^(i-1),emin); %��̬����ke
    
    %% ģ����������֯��ǰ���������
    %% ��һ�����,��ʱDFNN��ȫ�������ɹ۲����ݣ�����Ҫ��ʲô���������½������
    if e(i)<=ke && d_min<=kd
        aa1=RBF(dist(Center,All_TrainSamIn),1./Width');
        aa01=sum(aa1);aa11=aa1./(ones(s,1)*aa01);
        aa21=transf(aa11,All_TrainSamIn);
        W=All_TrainSamOut/aa21;
        outaa21=W*aa21;
        RMSE(i)=sqrt(sumsqr(All_TrainSamOut-outaa21)/(OutDim*i)); %���������ǵ�һ��������ĿǰΪֹ��RMSE
        RuleNum(i)=s;%ģ���������Ŀ
    end
    
    %% �ڶ����������������DFNN���нϺõķ���������ֻ�н��������Ҫ����
    if e(i)<=ke && d_min>kd
        a=RBF(dist(Center,All_TrainSamIn),1./Width');
        a0=sum(a);a1=a./(ones(s,1)*a0);
        a2=transf(a1,All_TrainSamIn);
        W=All_TrainSamOut/a2;
        outa2=W*a2;
        sse1=sumsqr(All_TrainSamOut-outa2)/(OutDim*i);
        RMSE(i)=sqrt(sse1);
        RuleNum(i)=s;
    end
    
    %% ���������,����RBF��Ԫ�ķ������������Ǻܺã���Ҫ����RBF�ڵ�Ŀ�Ⱥͽ������
    if e(i)>ke && d_min<=kd  
        Width(ind)=kw*Width(ind); %ind����ӽ���ǰ������ģ�����򣬶����Ƚ��е���
        aa=RBF(dist(Center,All_TrainSamIn),1./Width');
        aa0=sum(aa);aa1=aa./(ones(s,1)*aa0);
        aa2=transf(aa1,All_TrainSamIn);
        W=All_TrainSamOut/aa2;
        outaa2=W*aa2;
        RMSE(i)=sqrt(sumsqr(All_TrainSamOut-outaa2)/(i*OutDim));
        RuleNum(i)=s; 
    end
    
    %% ��������������󣬵�ǰ���������ĵ���С���볬���˿����ɱ߽����Ч�뾶����Ҫ����һ���µ�ģ������
    if e(i)>ke && d_min>kd
        All_Center=[All_Center Current_TrainSamIn]; %����һ��ģ���������ľ��ǵ�i������������
        Width_new=k*d_min; %����RBF��Ԫ�Ŀ�ȣ�������ص�����k*d_min
        Width=[Width Width_new];
        Center=All_Center';
        [u,v]=size(Center);        
        %������ģ������󣬼���RBF��Ԫ�����
        A=RBF(dist(Center,All_TrainSamIn),1./Width'); %RBF��Ԫ����������˲���
        A0=sum(A);%���
        A1=A./(ones(u,1)*A0);%��һ��
        A2=transf(A1,All_TrainSamIn);%A2Ӧ���������������H
        
        % ����½����޼�,��������N���ڵ���u*(r+1)ʱ���ż����������½��ʵ��޼�����������QR�ֽ��޷�ִ��
        if u*(r+1)<=N  %u�ǵ�ǰģ����������r������ά����NΪ��ǰ��������
            %��������½���
            tT=All_TrainSamOut';
            PAT=A2';
            [WW,AW]=orthogonalize(PAT); %��������������������������
            SSW=sum(WW.*WW)';SStT=sum(tT.*tT)';
            err=((WW'*tT)'.^2)./(SStT*SSW');
            errT=err';
            err1=zeros(u,OutDim*(r+1));
            err1(:)=errT;
            err21=err1';
            err22=sum(err21.*err21)/(OutDim*(r+1));
            err23=sqrt(err22);
            No=find(err23<kerr);
            if ~isempty(No) %��������½����޼�ģ������
                All_Center(:,No)=[];Center(No,:)=[]; %�޼���ģ������
                Width(:,No)=[];err21(:,No)=[];
                [uu,vv]=size(Center);
                AA=RBF(dist(Center,All_TrainSamIn),1./Width');
                AA0=sum(AA);
                AA1=AA./(ones(uu,1)*AA0);
                AA2=transf(AA1,All_TrainSamIn);
                W=All_TrainSamOut/AA2;
                outAA2=W*AA2;
                sse0=sumsqr(All_TrainSamOut-outAA2)/(i*OutDim);
                RMSE(i)=sqrt(sse0);
                RuleNum(i)=uu;
                w2T=W';ww2=zeros(uu,OutDim*(r+1));
                ww2(:)=w2T;
                w21=ww2';
            else  %����Ҫ�޼��Ļ�����ִ������
                W=All_TrainSamOut/A2;
                outA2=W*A2;
                sse0=sumsqr(All_TrainSamOut-outA2)/(OutDim*i);
                RMSE(i)=sqrt(sse0);
                RuleNum(i)=u;
                w2T=W';ww2=zeros(u,OutDim*(r+1));
                ww2(:)=w2T;
                w21=ww2';
            end
        else %����u*(r+1)>N
            W=All_TrainSamOut/A2;
            outA2=W*A2;
            sse0=sumsqr(All_TrainSamOut-outA2)/(OutDim*i);
            RMSE(i)=sqrt(sse0);
            RuleNum(i)=u;
            w2T=W';ww2=zeros(u,OutDim*(r+1));
            ww2(:)=w2T;
            w21=ww2';
        end  % if u*(r+1)<=N
    end
         
end

%% ѵ����Ԥ��
TA=RBF(dist(Center,TrainSamIn),1./Width');
TA0=sum(TA); [u,v]=size(Center);
TA1=TA./(ones(u,1)*TA0);
TA2=transf(TA1,TrainSamIn);
TrainNetOut=W*TA2;
TrainNetOutN=mapminmax('reverse',TrainNetOut,outputps); %ѵ�����������һ��   

%% ���Լ�Ԥ��
A=RBF(dist(Center,TestSamIn),1./Width');
SA=sum(A); [u,v]=size(Center);
A1=A./(ones(u,1)*SA);
A2=transf(A1,TestSamIn);
TestNetOut=W*A2;
TestNetOutN=mapminmax('reverse',TestNetOut,outputps);  %���Լ��������һ��  

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
plot(RuleNum,'k-','LineWidth',2);
title('Fuzzy rule generation');
xlabel('Input sample patterns');
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�
ylim([min(RuleNum)-1 max(RuleNum)+1]);

% figure,plot(e,'k');
% title('Actual output error e(i)');
% xlabel('Input sample patterns');

figure(2)
plot(RMSE,'k-','LineWidth',2)
xlabel('ѵ������','fontsize',9)
ylabel('RMSEֵ','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�
% xlim([0 100])
%ѵ�������ͼ

figure(3)
plot(TrainSamOutN,'k-','LineWidth',2)
hold on
plot(TrainNetOutN,'r--','LineWidth',2)
h=legend('Real values','Forecasting output');
set(h,'Fontsize',9);
xlabel('ѵ������','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.14 .16 .80 .80]);  %���� XLABLE��YLABLE���ᱻ�е�

%���Խ����ͼ
figure(4)
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
figure(5)
k=501:1000;
plot(k,TestError,'k-','LineWidth',2)
xlabel('��������','fontsize',9)
ylabel('Ԥ�����','fontsize',9)
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.17 .16 .79 .80]);  %���� XLABLE��YLABLE���ᱻ�е�
