

function Weights=DeriveWeights(RegressorMatrix,TrainSamOut_Window)

% ���ܣ� ���ݴ��������ݣ�����α�漼������ʶ���������(���Ȩֵ)Weights�Լ����������NetOut

% ���룺
% TrainSamIn_Window����ǰ�����ڵ�ѵ������������
% Center������
% Width_Left������
% Width_Right���ҿ��
% TrainSamOut_Window����ǰ�����ڵ�ѵ�����������

% �����
% Q:Hermitian����
% Weights:ģ������ĺ�����������Ȩֵ
% NetOut:��ǰ���������������������

Q = pinv(RegressorMatrix*RegressorMatrix'); %Q��Hermitian����,Q��M*M����M=RuleNum*(InDim+1)
Weights=(Q*RegressorMatrix*TrainSamOut_Window')'; %TrainSamOut_Window=1��N�У�Weights��1��M�е��͵�������С���˷�

end
