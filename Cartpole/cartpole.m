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

%% 计算可控矩阵
S_c = [B A*B A^2*B A^3*B];
fprintf('rank(S_c) = %d\n', rank(S_c));

%% 能观性矩阵
Q_o = [C;
       C*A;
       C*A^2;
       C*A^3];
fprintf('rank(Q_o) = %d\n', rank(Q_o));

%% LQR
Q = diag([500,5,1,1]);
R = eye(1);
K_lqr = lqr(A,B,Q,R);
disp('K_lqr = ');
disp(K_lqr);

