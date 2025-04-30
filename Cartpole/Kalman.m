%% 改进版3阶卡尔曼滤波（含加速度） - 更精确的速度/加速度估计

%% 参数设置
dt = 0.1;                   % 时间步长（必须与实际采样时间匹配）
accel_noise_mag = 0.1;      % 加速度过程噪声强度
measurement_noise = 0.1;    % 测量噪声标准差（根据传感器特性调整）

%% 系统模型（连续时间白噪声加速度模型）
A = [1 dt dt^2/2; 
     0 1 dt; 
     0 0 1];               % 状态转移矩阵
H = [1 0 0];               % 观测矩阵（仅观测位置）

%% 过程噪声协方差（Singer模型简化版）
G = [dt^2/2; dt; 1];       % 噪声输入矩阵
Q = G * G' * accel_noise_mag^2; % 过程噪声协方差

R = measurement_noise^2;   % 观测噪声协方差

%% 初始化
init_pos = 0;
init_vel = 0;
init_accel = 0;
x = [init_pos; init_vel; init_accel]; % 初始状态

% 初始协方差（反映初始估计的不确定性）
pos_var_init = 1;
vel_var_init = 1;
accel_var_init = 1;
P = diag([pos_var_init, vel_var_init, accel_var_init]);

% 生成更真实的测试轨迹（含加速度变化）
time = 0:dt:20;
true_acceleration = 0.5*sin(0.5*time) + 0.3*cos(2*time); % 复杂加速度变化
true_velocity = cumsum(true_acceleration)*dt;
true_position = cumsum(true_velocity)*dt;
noisy_measurements = true_position + randn(size(time))*measurement_noise;

% 预分配存储
N = length(time);
estimated_state = zeros(3,N);
innovations = zeros(1,N);

%% 卡尔曼滤波主循环（加入自适应调节）
for k = 1:N
    % --- 预测步骤 ---
    x = A * x;
    P = A * P * A' + Q;
    
    % --- 更新步骤 ---
    z = noisy_measurements(k);
    y = z - H * x;                  % 新息（innovation）
    S = H * P * H' + R;
    K = P * H' / S;
    
    x = x + K * y;
    P = (eye(3) - K * H) * P;
    
    % --- 存储结果 ---
    estimated_state(:,k) = x;
    innovations(k) = y;
    
end

%% 计算估计误差
pos_error = true_position - estimated_state(1,:);
vel_error = true_velocity - estimated_state(2,:);
accel_error = true_acceleration - estimated_state(3,:);

%% 可视化结果
figure('Position',[100 100 800 800])

% 位置结果
subplot(3,1,1);
plot(time, true_position, 'g', 'LineWidth', 2); hold on;
plot(time, noisy_measurements, 'b.', 'MarkerSize', 8);
plot(time, estimated_state(1,:), 'r', 'LineWidth', 2);
legend('真实位置','噪声观测','估计位置');
title(['位置估计 (RMSE=' num2str(rms(pos_error),'%.3f') ')']);
xlabel('时间 (s)'); ylabel('位置');
grid on;

% 速度结果
subplot(3,1,2);
plot(time, true_velocity, 'g', 'LineWidth', 2); hold on;
plot(time, estimated_state(2,:), 'r', 'LineWidth', 2);
legend('真实速度','估计速度');
title(['速度估计 (RMSE=' num2str(rms(vel_error),'%.3f') ')']);
xlabel('时间 (s)'); ylabel('速度');
grid on;

% 加速度结果
subplot(3,1,3);
plot(time, true_acceleration, 'g', 'LineWidth', 2); hold on;
plot(time, estimated_state(3,:), 'r', 'LineWidth', 2);
legend('真实加速度','估计加速度');
title(['加速度估计 (RMSE=' num2str(rms(accel_error),'%.3f') ')']);
xlabel('时间 (s)'); ylabel('加速度');
grid on;

