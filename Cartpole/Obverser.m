%% ϵͳ����
M = 0.2*0.2*0.25*1000;
m = 1*0.04*0.06*1000;
g = 9.8;
l =0.5;
I = 1/3*m*l^2;

%% ״̬�ռ䶨��
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
%% �ܹ۲��Է���
Q_o = [C;
       C*A;
       C*A^2;
       C*A^3];
fprintf('rank(Q_o) = %d\n', rank(Q_o));

%% ԭϵͳ����
% ��֤�۲�������
actual_poles = eig(A);
fprintf('ԭϵͳ����Ϊ:\n');
fprintf('%10.2f\n', actual_poles);

%% ������۲������
% �����۲�������(��ϵͳ�����3-5��)

obs_poles = [-15, -16, -17, -18];

% ����۲�������L
L = place(A', C', obs_poles)';
A_LC=A-L*C;

fprintf('�۲����������LΪ:\n');
fprintf('%10.2f\n', L);

% �۲���״̬���̾���
A_obs = A - L*C;
B_obs = [B L];

% ��֤�۲�������
actual_obs_poles = eig(A_obs);
fprintf('ʵ�ʹ۲�������Ϊ:\n');
fprintf('%10.2f\n', actual_obs_poles);
%%
% ��ʵϵͳ��̬
% x = x + 0.01*(A*x + B*u);
% �۲�����̬
% x_hat = x_hat + 0.01*(A_obs*x_hat + B*u + L*y);
   