clear all;
clc;

a = arduino('COM6', 'Uno', 'Libraries', 'Servo');
servo1 = servo(a, 'D4');
servo2=servo(a,'D7');
servo1_cal_angle=58;
servo2_cal_angle=69;
alpha1=0;
alpha2=0;
writePosition(servo1,(1/180)*(servo1_cal_angle+alpha1));
writePosition(servo2,(1/180)*(servo2_cal_angle+alpha2));