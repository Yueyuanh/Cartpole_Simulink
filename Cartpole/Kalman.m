%% �Ľ���3�׿������˲��������ٶȣ� - ����ȷ���ٶ�/���ٶȹ���

%% ��������
dt = 0.1;                   % ʱ�䲽����������ʵ�ʲ���ʱ��ƥ�䣩
accel_noise_mag = 0.1;      % ���ٶȹ�������ǿ��
measurement_noise = 0.1;    % ����������׼����ݴ��������Ե�����

%% ϵͳģ�ͣ�����ʱ����������ٶ�ģ�ͣ�
A = [1 dt dt^2/2; 
     0 1 dt; 
     0 0 1];               % ״̬ת�ƾ���
H = [1 0 0];               % �۲���󣨽��۲�λ�ã�

%% ��������Э���Singerģ�ͼ򻯰棩
G = [dt^2/2; dt; 1];       % �����������
Q = G * G' * accel_noise_mag^2; % ��������Э����

R = measurement_noise^2;   % �۲�����Э����

%% ��ʼ��
init_pos = 0;
init_vel = 0;
init_accel = 0;
x = [init_pos; init_vel; init_accel]; % ��ʼ״̬

% ��ʼЭ�����ӳ��ʼ���ƵĲ�ȷ���ԣ�
pos_var_init = 1;
vel_var_init = 1;
accel_var_init = 1;
P = diag([pos_var_init, vel_var_init, accel_var_init]);

% ���ɸ���ʵ�Ĳ��Թ켣�������ٶȱ仯��
time = 0:dt:20;
true_acceleration = 0.5*sin(0.5*time) + 0.3*cos(2*time); % ���Ӽ��ٶȱ仯
true_velocity = cumsum(true_acceleration)*dt;
true_position = cumsum(true_velocity)*dt;
noisy_measurements = true_position + randn(size(time))*measurement_noise;

% Ԥ����洢
N = length(time);
estimated_state = zeros(3,N);
innovations = zeros(1,N);

%% �������˲���ѭ������������Ӧ���ڣ�
for k = 1:N
    % --- Ԥ�ⲽ�� ---
    x = A * x;
    P = A * P * A' + Q;
    
    % --- ���²��� ---
    z = noisy_measurements(k);
    y = z - H * x;                  % ��Ϣ��innovation��
    S = H * P * H' + R;
    K = P * H' / S;
    
    x = x + K * y;
    P = (eye(3) - K * H) * P;
    
    % --- �洢��� ---
    estimated_state(:,k) = x;
    innovations(k) = y;
    
end

%% ����������
pos_error = true_position - estimated_state(1,:);
vel_error = true_velocity - estimated_state(2,:);
accel_error = true_acceleration - estimated_state(3,:);

%% ���ӻ����
figure('Position',[100 100 800 800])

% λ�ý��
subplot(3,1,1);
plot(time, true_position, 'g', 'LineWidth', 2); hold on;
plot(time, noisy_measurements, 'b.', 'MarkerSize', 8);
plot(time, estimated_state(1,:), 'r', 'LineWidth', 2);
legend('��ʵλ��','�����۲�','����λ��');
title(['λ�ù��� (RMSE=' num2str(rms(pos_error),'%.3f') ')']);
xlabel('ʱ�� (s)'); ylabel('λ��');
grid on;

% �ٶȽ��
subplot(3,1,2);
plot(time, true_velocity, 'g', 'LineWidth', 2); hold on;
plot(time, estimated_state(2,:), 'r', 'LineWidth', 2);
legend('��ʵ�ٶ�','�����ٶ�');
title(['�ٶȹ��� (RMSE=' num2str(rms(vel_error),'%.3f') ')']);
xlabel('ʱ�� (s)'); ylabel('�ٶ�');
grid on;

% ���ٶȽ��
subplot(3,1,3);
plot(time, true_acceleration, 'g', 'LineWidth', 2); hold on;
plot(time, estimated_state(3,:), 'r', 'LineWidth', 2);
legend('��ʵ���ٶ�','���Ƽ��ٶ�');
title(['���ٶȹ��� (RMSE=' num2str(rms(accel_error),'%.3f') ')']);
xlabel('ʱ�� (s)'); ylabel('���ٶ�');
grid on;

