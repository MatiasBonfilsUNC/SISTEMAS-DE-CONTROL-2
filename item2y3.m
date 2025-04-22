
pkg load control
pkg load io
pkg load signal
ruta_archivo = "C:\\Users\\user\\Desktop\\FACULTAD\\Sistemas de Control 2\\Curvas_Medidas_RLC_2025_CSV.csv";
datos = dlmread(ruta_archivo, ';');
tiempo     = datos(1:end,1);
corriente  = datos(1:end,2);
vcap       = datos(1:end,3);
vin        = datos(1:end,4);
vout       = datos(1:end,5);
vin_12     = 12;

% Gráficas iniciales
figure(1)
subplot(4,1,1); plot(tiempo, vcap, 'b'); title('Tensión Capacitor , V_t'); grid on; hold on;
subplot(4,1,2); plot(tiempo, corriente, 'b'); title('Corriente , I_t'); grid on; hold on;
subplot(4,1,3); plot(tiempo, vin, 'b'); title('Tensión de entrada , U_t'); grid on; hold on;
subplot(4,1,4); plot(tiempo, vout, 'b'); title('Tensión de salida , U_t'); grid on; hold on;

% === ANALISIS DEL CAPACITOR ===
tiempo_recorte = tiempo(980:1500);
vcap_recorte   = vcap(980:1500);
vin_recorte    = vin(980:1500);

vin_recorte(vin_recorte == 0) = eps;
razon = vcap_recorte ./ vin_recorte;

figure(2);
subplot(2,1,1);
plot(tiempo_recorte, razon, 'r');
title('Relación V_{cap} / V_{in} entre muestras 980 y 1500');
xlabel('Tiempo');
ylabel('V_{cap} / V_{in}');
grid on;

subplot(2,1,2);
plot(tiempo_recorte, vcap_recorte, 'b'); hold on;
title('Tensión en el capacitor entre muestras 980 y 1500');
xlabel('Tiempo');
ylabel('V_{cap}');
grid on;

% Puntos de referencia
t1 = datos(1035,1); y1 = datos(1030,3);
t2 = datos(1070,1); y2 = datos(1070,3);
t3 = datos(1105,1); y3 = datos(1105,3);
plot([t1 t2 t3], [y1 y2 y3], 'ro', 'MarkerFaceColor', 'g');
legend('V_{cap}', 'Puntos seleccionados');

% Modelo de capacitor
k_v = datos(2000,3)/vin_12;
y1 = y1/vin_12; y2 = y2/vin_12; y3 = y3/vin_12;
k1 = y1/k_v - 1; k2 = y2/k_v - 1; k3 = y3/k_v - 1;
b_v = 4*(k1^3)*k3 - 3*(k1^2)*(k2^2) - 4*(k2^3) + (k3^2) + 6*k1*k2*k3;
alfa1_v = (k1*k2 + k3 - sqrt(b_v))/(2*(k1^2 + k2));
alfa2_v = (k1*k2 + k3 + sqrt(b_v))/(2*(k1^2 + k2));
beta_v = (k1+alfa2_v)/(alfa1_v-alfa2_v);
T1_v = -(t1 - 0.01)/log(alfa1_v);
T2_v = -(t1 - 0.01)/log(alfa2_v);
T3_v = beta_v*(T1_v - T2_v) + T1_v;

G_v = tf(k_v*[T3_v 1], conv([T1_v 1], [T2_v 1]))

% Simulación Vcap
vcap_modelo = lsim(G_v, vin_recorte, tiempo_recorte);
figure(3);
plot(tiempo_recorte, vcap_recorte, 'b', 'DisplayName', 'V_{cap} real'); hold on;
plot(tiempo_recorte, vcap_modelo, 'r--', 'DisplayName', 'V_{cap} modelo');
xlabel('Tiempo (s)');
ylabel('Tensión en el capacitor');
title('Comparación: V_{cap} real vs modelo');
legend(); grid on;

%OBTENER LOS VALORES R,  L y C
%sabiendo que R=220 Ohms y que el numerador es igual a 1 (el cero extra puede haber aparecido %producto de la selección de puntos
[num, den] = tfdata(G_v, "vector");
R = 220;
a2 = den(1);  % coeficiente de s^2
a1 = den(2);  % coeficiente de s^1
% Se asume que la función de transferencia teórica es:
% G(s) = 1 / (L*C*s^2 + R*C*s + 1)
%% Así se identifican:
%   L * C = den(1)
%   R * C = den(2)
% Calcular C a partir de R * C = den(2)
C = den(2) / R;
% Calcular L a partir de L * C = den(1)
L = den(1) / C;
%% === VALIDACIÓN CON LA SERIE DE CORRIENTE (t >= 0.05 s) ===
% Para un RLC en serie la FT para la corriente es:
%     G_i(s) = I(s)/V_in(s) = s*C / (L*C*s^2 + R*C*s + 1)
G_i = tf([C, 0], [L*C, R*C, 1]);

% Seleccionar la serie de corriente a partir de t = 0.05 s
idx_val = find(tiempo >= 0.05);
tiempo_val   = tiempo(idx_val);
corriente_val = corriente(idx_val);
vin_val      = vin(idx_val);  % Supone que la entrada es la misma

% Simular la respuesta del modelo de corriente
I_modelo = lsim(G_i, vin_val, tiempo_val);

figure(4);
plot(tiempo_val, corriente_val, 'b', 'DisplayName', 'I_{real}');
hold on;
plot(tiempo_val, I_modelo, 'r--', 'DisplayName', 'I_{modelo}');
xlabel('Tiempo (s)');
ylabel('Corriente (A)');
title('Validación del modelo: Corriente real vs modelo (t >= 0.05 s)');
legend();
grid on;

