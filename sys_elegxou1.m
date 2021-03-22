% 21st of March, 2021
% SYS_201 First lab, second part(ZN)

clear all
close all
clc

% Define the 3rd Degree open loop system
Ks = 1;
T1 = 2;
T2 = 2;
T3 = 2;

tmp1 = tf(1, [T1 1]);  % tf stands for transfer function
tmp2 = tf(1, [T2 1]);
tmp3 = tf(1, [T3 1]);

sys1 = Ks*tmp1*tmp2*tmp3;


for Kp = 1:0.5:20
    C = pid(Kp);  % define a p cnotroller
    T = feedback(C*sys1,1);  % connect it to our plant, sys1
    plantInfo = stepinfo(T); 
    %below, we check if T fluctuates at the same Amplitude for infinity
    if plantInfo.PeakTime == Inf;
        fprintf('The Kp_Crit value is %f \n', Kp);
        Kp_crit = Kp;  % Kp_critical is found!
        break
    end
end

%Find the period of T(which is T_crit)
[y,t]=step(T);
[pks,locs] = findpeaks(y,t);
T_crit = max(diff(locs));
fprintf('The T_Crit value is %f \n', T_crit);


% We have now gathered the values we want to create the control system
% Below is the implementation of the Ziegler-Nichols model.

%P Control
Kp = 0.5*Kp_crit;
T_max = 100;  % random value
PID_controller = pidstd(Kp);  
p_step = feedback(sys1*PID_controller,1);
    

%PI Control
Kp = 0.45*Kp_crit;
Ti = 0.85*T_crit;
T_max = 100;  % random value
PID_controller = pidstd(Kp,Ti);  
pi_step = feedback(sys1*PID_controller,1);
    

    
% For PID Control
Kp = 0.6*Kp_crit;
Ti = 0.5*T_crit;
Td = 0.12*T_crit;
T_max = 30*Td;
PID_controller = pidstd(Kp,Ti,Td);
pid_step = feedback(sys1*PID_controller,1);

%plot all the above 
step(sys1,p_step,pi_step,pid_step);
fprintf('The P, PI and PID responses are projected in one plot \nat a seperate window\n');
    
    
%pidTuner(sys1)