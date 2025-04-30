%% 系统参数
M = 0.2*0.2*0.25*1000;
m = 1*0.04*0.06*1000;
g = 9.8;
l =0.5;
I = 1/3*m*l^2;

%% 状态空间定义
a23 = -m*m*g*l*l/(I*(m+M)+M*m*l*l);
a43 = m*g*l*(M+m)/(I*(m+M)+M*m*l*l);
b2 = (I+m*l*l)/(I*(m+M)+M*m*l*l);
b4 = -m*l/(I*(m+M)+M*m*l*l);

A = [0 1  0  0;
     0 0 a23 0;
     0 0  0  1;
     0 0 a43 0];

B = [0;
     b2;
     0;
     b4];

C =[1 0 0 0]; 
%% 能观测性分析
Q_o = [C;
       C*A;
       C*A^2;
       C*A^3];
fprintf('rank(Q_o) = %d\n', rank(Q_o));

%% 原系统极点
% 验证观测器极点
actual_poles = eig(A);
fprintf('原系统极点为:\n');
fprintf('%10.2f\n', actual_poles);

%% 龙伯格观测器设计
% 期望观测器极点(比系统极点快3-5倍)

obs_poles = [-15, -16, -17, -18];

% 计算观测器增益L
L = place(A', C', obs_poles)';
A_LC=A-L*C;

fprintf('观测器增益矩阵L为:\n');
fprintf('%10.2f\n', L);

% 观测器状态方程矩阵
A_obs = A - L*C;
B_obs = [B L];

% 验证观测器极点
actual_obs_poles = eig(A_obs);
fprintf('实际观测器极点为:\n');
fprintf('%10.2f\n', actual_obs_poles);
%%
% 真实系统动态
% x = x + 0.01*(A*x + B*u);
% 观测器动态
% x_hat = x_hat + 0.01*(A_obs*x_hat + B*u + L*y);
   