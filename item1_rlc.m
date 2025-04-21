% ITEM 1 - RLC
close all; clear all; clc

pkg load control
pkg load signal

R = 220; % Resistencia en ohmios
L = 500e-3; % Inductancia en henrios
C = 2.2e-6; % Capacitancia en faradios

% Definimos los vectores de estados
A = [-R/L, -1/L; 1/C, 0];
B = [1/L; 0];
C = [R, 0];
D = [0];

% Obtenemos la función de transferencia a partir del modelo en espacio de estados
[num, den] = ss2tf(A, B, C, D);
G = tf(num, den);

% Calcular los polos de la función de transferencia
polos = pole(G);
% Averiguamos cual es el polo más grande y más chico
abs_polos = abs(real(polos));
polo_menor = min(abs_polos)
polo_mayor = max(abs_polos)


% Sabiendo que el tiempo de establecimiento para un sistema de  segundo orden es
%igual a  t=4/(psita.wn), y además el denominador la parte real del polo más dominante, tenemos
%podemos observar que el sistema no logra  establecerse  antes del cambio de signo a los 10 ms

%por un lado, usamos el polo mayor para determinar el tiempo de muestreo ya que eso nos va a %permitir no esconder o poder ver las dinámicas rápidas del sistema
tR = -log(0.95)/abs(polo_mayor)
%por el otro lado, utilizando el polo más cercano al origen podemos calcular un tiempo de %simulacion
tL = -log(0.05)/abs(polo_menor)

td = abs((2*pi/imag(min(polos)))/100)
%buscamos un tiempo de muestreo
t_m = min(tR/4, td)
t_sim = 0.2;

% simulamos con una entrada de 0V
t = linspace(0, t_sim, t_sim/t_m);
u = linspace(0, 0, t_sim/t_m);

% Creamos la secuencia de pulsos de 12v a -12v
u(t > 0.01) = 12*(-1).^(floor((t(t > 0.01) - 0.01)/0.01));

%CONDICIONES INCIALES NULAS
VR(1) = 0;
I(1) = 0;
VC(1) = 0;
x = [I(1) VC(1)]';
x0 = [0 0]';



for i = 1:(t_sim/t_m) - 1;
    x_p = A*(x - x0) + B*u(i);
  x = x + x_p*t_m;
  y = C*x;

  VR(i+1) = y;
  I(i+1) = x(1);
  VC(i+1) = x(2);
end

figure;
subplot(4,1,1);
plot(t, u);
title('Tension de entrada del sistema');
xlabel('Tiempo (s)');
ylabel('Voltaje (V)');
grid on

subplot(4,1,2);
plot(t, VC);
title('Tensión en el capacitor');
xlabel('Tiempo (s)');
ylabel('Voltaje (V)');
grid on

subplot(4,1,3);
plot(t, I);
title('Corriente ’);
xlabel('Tiempo (s)');
ylabel('Corriente (A)');
grid on;

subplot(4,1,4);
plot(t, VR);
title('Tension en la resistencia');
xlabel('Tiempo (s)');
ylabel('Voltaje (V)');
grid on;

