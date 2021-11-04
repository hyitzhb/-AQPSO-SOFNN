% ����Ӧ��������Ⱥ�Ż�����֯ģ��������
% ǰ�������ͽṹ������Ӧ��������Ⱥ
% �����������С����
% ����ʱ������Ԥ��
%% ���
clc;
clear all;
close all;
%% ����׼��
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
%��������
x5=x(636:1135); x6=x(630:1129);
x7=x(624:1123); x8=x(618:1117);
TestSamInN=[x5;x6;x7;x8];
TestSamOutN=x(642:1141);
TestSamNum=size(TestSamInN,2); %TestSamNum����������500
%��һ��
[TrainSamIn,inputps]=mapminmax(TrainSamInN,0,1);   %TrainSamInΪ��һ����ѵ����������
[TrainSamOut,outputps]=mapminmax(TrainSamOutN,0,1);%TrainSamOutΪ��һ����ѵ���������
TestSamIn=mapminmax('apply',TestSamInN,inputps);   %TestSamInΪ��һ����Ĳ�����������
%% ��������
PopNum = 50;      %��Ⱥ��ģ
RuleNum_max = 15; %���ģ��������
RuleNum_best_his = []; %��¼ÿһ��������ģ��������
pop_RuleNum = round((RuleNum_max-1)*rand(PopNum,1)+1);   %ÿһ��������Я����ģ����������PopNum��1��,1-15֮����������
pop_dim = InDim*pop_RuleNum+InDim*pop_RuleNum;       %PopNum��1��,���߿ռ�ά��=������Ŀ+�����Ŀ,ֻ�����ĺͿ�����ֲ�������Ѱ��
Maxstep = 200;  %����������
pop_bound_center = [0  1];    %���ķ�Χ
pop_bound_width =  [0.4 1.2]; %��ȷ�Χ
%��Ⱥ��ʼ��
pop=zeros(2*InDim,RuleNum_max,PopNum);   %2*InDim�У�RuleNum_max�У�PopNumҳ
for i=1:PopNum
    pop(1:InDim,1:pop_RuleNum(i),i) = pop_bound_center(1)+rand(InDim,pop_RuleNum(i))*(pop_bound_center(2)-pop_bound_center(1));  %���ģ�ǰ4��
    pop(InDim+1:2*InDim,1:pop_RuleNum(i),i) = pop_bound_width(1)+rand(InDim,pop_RuleNum(i))*(pop_bound_width(2)-pop_bound_width(1));  %��ȣ���4��
end

%������С���˻�ȡ���Ȩ��
for i=1:PopNum
    %     i=2    %������
    [fit(i),Weights(i).Weights]= fitness(pop(:,:,i),pop_RuleNum(i),TrainSamIn,TrainSamOut);
    f_pbest(i) = fit(i);
end

% ������Ⱥ��Ӧ��ֵ
pbest = pop;   %��ʼ��ʱpbest������Ⱥ����
gbest = zeros(2*InDim,RuleNum_max,1);
g = min(find(f_pbest == min(f_pbest(1:PopNum))));
gbest = pbest(:,:,g);     %gbestΪ��ʼ��ʱ��ȡ��ȫ������λ��
f_gbest = f_pbest(g);     %f_gbestΪȫ�����Ž��Ӧ����Ӧ��ֵ
Weights_best= Weights(g).Weights;
RuleNum_bset=pop_RuleNum(g);
%% �������
for step = 1:Maxstep
    step
    %��¼gbest����Ӧ��ֵ
    f_gbest_his(step)=f_gbest;  %�����˳�ʼf_gbest������û�����һ�ε�����f_gbest
    %�����½�������չϵ��
    %���1���̶�
    b=0.8;     %ȡ�̶�������չϵ��
    %���2�������½�
    b = 0.368+(1.781-0.368)*(Maxstep-step)/Maxstep;    %bΪ����-����ϵ������1�����½���0.5
    %���3������Ӧ
    b=0.368+(1.781-0.368)*(1/(1+exp(20*(step/Maxstep-0.5))));
    b_his(step)=b;             %��¼b��ֵ
    mbest =sum(pbest,3)/PopNum;   %mbestΪƽ�����λ��
    dw=0.6+(1.2-0.6)*(1/(1+exp(20*(step/Maxstep-0.5))));
    cf=0.01+(0.25-0.01)*(1/(1+exp(20*(step/Maxstep-0.5))));
    for i = 1:PopNum  %PopNumΪ��Ⱥ��ģ
        %λ�ø���
        eta=exp(-(pop(:,1:pop_RuleNum(i),i)-gbest(:,1:pop_RuleNum(i))).^2/(dw).^2); %����������Ӧ����
        a = rand(2*InDim,pop_RuleNum(i)); u = rand(2*InDim,pop_RuleNum(i));  %a��uΪ��ά����
        p =eta.* a.*pbest(:,1:pop_RuleNum(i),i)+(1-eta).*(1-a).*gbest(:,1:pop_RuleNum(i));
        pop(:,1:pop_RuleNum(i),i) = p + b*abs(mbest(:,1:pop_RuleNum(i))-pop(:,1:pop_RuleNum(i),i)).*...
            log(1./u).*(1-2*(u >= 0.5));       
        %�߽���
        for r=1:InDim   %���ļ��
            for j=1:pop_RuleNum(i)
                if pop(r,j,i)<pop_bound_center(1)
                    pop(r,j,i)=pop_bound_center(1).*(1+cf.*rand);
                end
                if pop(r,j,i)>pop_bound_center(2)
                    pop(r,j,i)=pop_bound_center(2).*(1-cf.*rand);
                end
            end
        end
        for r=InDim+1:2*InDim   %��ȼ��
            for j=1:pop_RuleNum(i)
                if pop(r,j,i)<pop_bound_width(1)
                    pop(r,j,i)=pop_bound_width(1).*(1+cf.*rand);
                end
                if pop(r,j,i)>pop_bound_width(2)
                    pop(r,j,i)=pop_bound_width(2).*(1-cf.*rand);
                end
            end
        end    
        %��Ӧ�ȼ��㣬������Ȩ��
        [fit(i),Weights(i).Weights]= fitness(pop(:,:,i),pop_RuleNum(i),TrainSamIn,TrainSamOut);
        %��������λ��pbset����
        if fit(i) < f_pbest(i)
            pbest(:,:,i) = pop(:,:,i);  %���߿ռ����
            f_pbest(i) = fit(i);    %Ŀ��ռ����
        end
        %ȫ������λ��gbest����
        if f_pbest(i) < f_gbest
            gbest = pbest(:,:,i);    %���߿ռ����
            f_gbest = f_pbest(i);  %Ŀ��ռ����
            Weights_best= Weights(i).Weights;
            RuleNum_bset=pop_RuleNum(i);
        end
    end 
    %��¼��ѵ�ģ��������
    RuleNum_best_his=[RuleNum_best_his RuleNum_bset];
end

%% ������ģ���Ⱥ�Ȩֵ
Center=gbest(1:InDim,1:RuleNum_bset);        %ǰ40��Ԫ��������
Width=gbest(InDim+1:2*InDim,1:RuleNum_bset);     %��40��Ԫ���ǿ��
Weights=Weights_best;

%% ѵ����Ԥ��
NormValueMatrix=[]; %��գ��Ա�ѵ����Ԥ��
RegressorMatrix=[];%��գ��Ա���Լ�Ԥ��
NormValueMatrix=GetMeNormValue(TrainSamIn,Center,Width);%����ȫ��ѵ�������Ĺ�������RuleUnitOut
RegressorMatrix=GetMeRegressorMatrix(NormValueMatrix,TrainSamIn);%����ȫ��ѵ�������Ļع���RegressorMatrix
TrainNetOut=Weights*RegressorMatrix;%NetOutΪ�������
TrainNetOutN=mapminmax('reverse',TrainNetOut,outputps); %ѵ�����������һ��

%% ����ѵ����RMSE��APE������
TrainError=TrainSamOutN-TrainNetOutN;
TrainRMSE=sqrt(sum(TrainError.^2)/TrainSamNum);
TrainAPE=sum(abs(TrainError)./abs(TrainSamOutN))/TrainSamNum;
TrainAccuracy=sum(1-abs(TrainError./TrainSamOutN))/TrainSamNum;
disp(['TrainRMSE     == ',num2str(TrainRMSE),' ']); %ѵ��RMSE
disp(['TrainAPE      == ',num2str(TrainAPE),' ']); %ѵ��APE
disp(['TrainAccuracy == ',num2str(TrainAccuracy),' ']); %ѵ������

%% ���Լ�Ԥ��
NormValueMatrix=[]; %��գ��Ա���Լ�Ԥ��
RegressorMatrix=[]; %��գ��Ա���Լ�Ԥ��
%���ȼ��㴰���������Ĺ���������NormValueMatrix
NormValueMatrix=GetMeNormValue(TestSamIn,Center,Width);
%���ݹ�������NormValue���õ��ع�������RegressorMatrix
RegressorMatrix=GetMeRegressorMatrix(NormValueMatrix,TestSamIn); %RegressorMatrix��M��N�У�M=RuleNum*(InDim+1)��N�Ǵ�����������
TestNetOut=Weights*RegressorMatrix;%NetOutΪ�������
TestNetOutN=mapminmax('reverse',TestNetOut,outputps); %ѵ�����������һ��

%% ������Լ�RMSE��APE������
TestError=TestSamOutN-TestNetOutN;
TestRMSE=sqrt(sum(TestError.^2)/TestSamNum);
TestAPE=sum(abs(TestError)./abs(TestSamOutN))/TestSamNum;
TestAccuracy=sum(1-abs(TestError./TestSamOutN))/TestSamNum;
disp(['TestRMSE      == ',num2str(TestRMSE),' ']); %����RMSE
disp(['TestAPE       == ',num2str(TestAPE),' ']); %����APE
disp(['TestAccuracy  == ',num2str(TestAccuracy),' ']); %���Ծ���

%% ��ͼ
figure; %��������ϵ���仯����
plot(b_his,'k-','LineWidth',2);
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�

figure;  %ģ��������
plot(RuleNum_best_his,'k-','LineWidth',2);
xlabel('Number of iterations','fontsize',10,'fontname','Times New Roman')
ylabel('Number of fuzzy rules','fontsize',10,'fontname','Times New Roman')
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.16 .16 .80 .74]);  %���� XLABLE��YLABLE���ᱻ�е�
ylim([0 16])

figure;  %�����Ӧ��ֵ��������
plot(f_gbest_his,'k-','LineWidth',2);
xlabel('Number of iterations','fontsize',10,'fontname','Times New Roman')
ylabel('\itf\iti\itt','fontsize',10,'fontname','Times New Roman')
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.18 .16 .78 .74]);  %���� XLABLE��YLABLE���ᱻ�е�

%ѵ�������ͼ
figure;
plot(TrainSamOutN,'k-','LineWidth',2)
hold on
plot(TrainNetOutN,'r--','LineWidth',2)
h=legend('Real values','Forecasting output');
set(h,'Box','off','Fontsize',10,'fontname','Times New Roman');
xlabel('Training samples','fontsize',10,'fontname','Times New Roman')
ylabel('Desired and predicted outputs','fontsize',10,'fontname','Times New Roman')
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.14 .16 .80 .80]);  %���� XLABLE��YLABLE���ᱻ�е�

%���Խ����ͼ
figure;
kk=TrainSamNum+1:TrainSamNum+TestSamNum;
plot(kk,TestSamOutN,'k-','LineWidth',2)
hold on
plot(kk,TestNetOutN,'r--.','LineWidth',2,'Markersize',5)
h=legend('Desired output','Predicted output');
set(h,'Box','off','Fontsize',10,'fontname','Times New Roman','location','northeast');
xlabel('Testing samples','fontsize',10,'fontname','Times New Roman')
ylabel('Outputs','fontsize',10,'fontname','Times New Roman')
ylim([0.2 1.6])
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.14 .16 .80 .80]);  %���� XLABLE��YLABLE���ᱻ�е�

%�����������
figure;
kk=TrainSamNum+1:TrainSamNum+TestSamNum;
plot(kk,TestError,'k-','LineWidth',2)
xlabel('Testing samples','fontsize',10,'fontname','Times New Roman')
ylabel('Prediction error','fontsize',10,'fontname','Times New Roman')
set(gcf,'Position',[100 100 320 250]);
set(gca,'Position',[.17 .16 .79 .80]);  %���� XLABLE��YLABLE���ᱻ�е�

%% �洢���
save RuleNum_best_his RuleNum_best_his
save f_gbest_his f_gbest_his
save TestSamOutN TestSamOutN
save TestNetOutN TestNetOutN
save TestError TestError