clear all
close all

sys3 = tf(1,[0.1,1])^2;
sys4 = tf(1,[0.5,1])^2;
sys5 = tf(1,[1,1])^2;
sys6 = tf(1,[0.05,0.6,1]); % (0.1*s+1)*(0.5*s+1) (using handwritten math)
sys7 = tf(1,[0.8,2.4,1]);  % (0.4*s+1)*(2*s+1)
sys8 = tf(1,[5,1])*tf(1,[1,1]);  % (s+1)*(5*s+1) (using in-programm multiplication)
sys9 = tf(1,[0.1,1])*tf(1,[10,1]);  % (0.1*s+1)*(10*s+1)
sys10 = tf(1,[0.1,1])^4;
sys11 = tf(1,[0.5,1])^4;
sys12 = tf(1,[1,1])^4;
sys13 = tf(1,[0.5,1])*tf(1,[0.1,1])^3;
sys14 = tf(1,[2.5,1])*tf(1,[0.5,1])^3;

step(sys3,sys4,sys5,sys6,sys7,sys8,sys9,sys10,sys11,sys12,sys13,sys14);
