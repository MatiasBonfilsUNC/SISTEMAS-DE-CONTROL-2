% Parámetros del circuito
R = 220;     % Resistencia (Ohms)
L = 500e-3;   % Inductancia (H)
C = 2.2e-6;   % Capacitancia (F)
V_in_amp = 12;  % Amplitud de la fuente (V)
T_switch = 10e-3; % Tiempo de conmutación (10 ms)
dt = 1e-7;       % Paso de tiempo (ajustar según necesidad!)
T_total = 80e-3; % Tiempo total de simulación (80 ms)

% Vectores de tiempo y entrada
t = 0:dt:T_total;
N = length(t);
V_in = V_in_amp * (-1).^floor(t / T_switch); % Conmuta cada 10ms

% Matrices de estado (dx/dt = A*x + B*u)
A = [-R/L, -1/L;
      1/C,   0];
B = [1/L;
        0];

% Condiciones iniciales (I_L=0, V_C=0)
x = zeros(2, N);
x(:, 1) = [0; 0]; % [I_L; V_C]

% Integración con Euler
for n = 1:N-1
    u = V_in(n);
    dxdt = A * x(:, n) + B * u;
    x(:, n+1) = x(:, n) + dxdt * dt;
end

% Cálculo de voltaje en la resistencia (V_R = I_L*R)
V_R = R * x(1,:);

% Graficación (4 subplots)
figure;

% 1. Corriente en el inductor (corrección clave: sintaxis de plot)
subplot(4,1,1);
plot(t, x(1,:));  % <-- Se eliminó la coma y se cerró correctamente
grid on;
xlabel('Tiempo (s)');
ylabel('I_L (A)');
title('Corriente en el Inductor');

% 2. Voltaje en el capacitor
subplot(4,1,2);
plot(t, x(2,:));
grid on;
xlabel('Tiempo (s)');
ylabel('V_C (V)');
title('Voltaje en el Capacitor');

% 3. Voltaje en la resistencia
subplot(4,1,3);
plot(t, V_R);
grid on;
xlabel('Tiempo (s)');
ylabel('V_R (V)');
title('Voltaje en la Resistencia');

% 4. Voltaje de entrada
subplot(4,1,4);
plot(t, V_in);
grid on;
xlabel('Tiempo (s)');
ylabel('V_{in} (V)');
title('Voltaje de Entrada');

