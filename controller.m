clear all;
close all;
clc;

cam=webcam("Logi C310 HD WebCam");%calling the webcam
%for craeting the path list later on
path=[];


% capturing an image before balancing
 e=snapshot(cam);
 e=rgb2gray(e);
 e=imcrop(e,[0 0 420 420]);
 imshow(e);
 [center,radius]=imfindcircles(e,[30,80],"ObjectPolarity","bright","Sensitivity",0.9,"EdgeThreshold",0.3);
      viscircles(center,radius);


a = arduino('COM6', 'Uno', 'Libraries', 'Servo');% calling the arduino board
servo1 = servo(a, 'D4');% servo motor 1 connected to the 4th port
servo2 = servo(a,'D7'); % servo motor 2 connected to the 7th port

%servo motor calibrated angle
servo1_cal_angle=58;
servo2_cal_angle=69;



%keeping the plate flat before balancing the plate
theta1=0;
theta2=0;
writePosition(servo1,(1/180)*(servo1_cal_angle+theta1));
writePosition(servo2,(1/180)*(servo2_cal_angle+theta2));


%defining the inital pre error value for the derivative control
pre_error_x=0;
pre_error_y=0;


z=0;

while true
    % capturing contineous image of the ball for image processing
     e=snapshot(cam);
     e=rgb2gray(e);
     e=imcrop(e,[0 0 420 420]);
     figure(1);
     hold on;
     imshow(e);
    %capturing the location of the centers of the ball while it is travelling
     [center,radius]=imfindcircles(e,[30,80],"ObjectPolarity","bright","Sensitivity",0.9,"EdgeThreshold",0.3);
      viscircles(center,radius);
    %defining the center of the plate and putting a circle in the center
    %location
      viscircles([210 210],40);
      center;
      path=[path;center];
      
      
    %defining the origin of the plate
      x_coordinates=[210;210;210;];
      y_coordinates=[210;210;210;];
      
      
    %capturing the x-coordinate and y=coordinate of the ball
     x_coordinates=[x_coordinates;path(:,1)];
     y_coordinates=[y_coordinates;path(:,2)];
    
    %plotting the center of the ball

     plot(x_coordinates(end),y_coordinates(end),'m*','MarkerSize',10);

     hold off;
 
    %distance from the center of the plate in the x-direction
     error_x=x_coordinates(end)-210;

    
     
    %distance from the center of the plate in the y-direction
     error_y=y_coordinates(end)-210;
 
    %defining the distance from the center of the plate
     distance=((error_x)^2+(error_y)^2)^0.5;
     
     
     
     
     
     
%----------------------------------------------------------------------------%
     %Implementing proportional-integral-derivative control

     
     k_p_x=0.036;
     k_p_y=0.029;
     
     k_d_x=0.01;%0.017; 
     k_d_y=0.01;%0.017;
     

    
     %for derivative control
     delta_x=(error_x-pre_error_x);
     
     delta_y=(error_y-pre_error_y);
     

   
       
     
     theta1=k_p_x*error_x+k_d_x*delta_x;
     theta2=k_p_y*error_y+k_d_y*delta_y;
     
     
     writePosition(servo1,(1/180)*(servo1_cal_angle+theta1));
     writePosition(servo2,(1/180)*(servo2_cal_angle+theta2));
     
     pre_error_x=x_coordinates(end)-210;
     pre_error_y=y_coordinates(end)-210;
     

     
   %if the ball get stuck in a position, 35 away from the center then we try to get the ball
   %to the center.  
     if abs(x_coordinates(end-1)-x_coordinates(end))<=0.5 & distance >= 35 
     theta1=(17/210)*error_x;
     theta2=(17/210)*error_y;
      writePosition(servo1,(1/180)*(servo1_cal_angle+theta1));
      writePosition(servo2,(1/180)*(servo2_cal_angle+theta2));

     end 

z=z+3;
t=size(x_coordinates(:,1));
figure(2);
hold on;
plot(z,error_x,'*');
ylim([-300 300]);
xlim([0 z+100]);
xlabel('time');
ylabel('error_x');
grid on;
hold off;

figure(3);
hold on;
plot(z,error_y,'*');

xlim([0 z+100]);
ylim([-300 300]);
xlabel('time');
ylabel('error_y');
grid on;
hold off;


end