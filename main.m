clear all;
clc;

cam=webcam("Logi C310 HD WebCam");%calling the webcam
path=[];

% capturing an image before balancing
 e=snapshot(cam);
 e=rgb2gray(e);
 e=imcrop(e,[0 0 420 420]);
 imshow(e);


a = arduino('COM6', 'Uno', 'Libraries', 'Servo');% calling the arduino board
servo1 = servo(a, 'D4');% servo motor 1 connected to the 4th port
servo2 = servo(a,'D7'); % servo motor 2 connected to the 7th port

%keeping the plate flat before balancing the plate
theta1=0;
theta2=0;
writePosition(servo1,(1/180)*(64+theta1));
writePosition(servo2,(1/180)*(71+theta2));


while true
    % capturing contineous image of the ball for image processing
     e=snapshot(cam);
     e=rgb2gray(e);
     e=imcrop(e,[0 0 420 420]);
     imshow(e);
    %capturing the location of the centers of the ball while it is travelling
     [center,radius]=imfindcircles(e,[30,80],"ObjectPolarity","bright","Sensitivity",0.9,"EdgeThreshold",0.3);
      viscircles(center,radius);
    %defining the center of the plate and putting a circle in the center
    %location
      viscircles([210 210],40);
      center;
      path=[path;center];
      
      x_coordinates=210;
      y_coordinates=210;
    %capturing the x-coordinate and y=coordinate of the ball
     x_coordinates=[x_coordinates;path(:,1)];
     y_coordinates=[y_coordinates;path(:,2)];
    
    %plotting the center of the ball
     hold on;
     plot(x_coordinates(end),y_coordinates(end),'m*','MarkerSize',10);
     hold off;

 
    %distance from the center of the plate in the x-direction
     distance_x=x_coordinates(end)-210;
     
    %distance from the center of the plate in the y-direction
     distance_y=y_coordinates(end)-210;
     
    %defining the distance from the center of the plate
     distance=((distance_x)^2+(distance_y)^2)^0.5
     
     
    %rotating the servo motors according to the distance of the ball from the
    %center.Farther it is from the  center the motor will rotate to a
    %greater angle in our case it is 10 degree(i.e maximum angle)
     theta1=(12/210)*distance_x;
     theta2=(12/210)*distance_y;
     writePosition(servo1,(1/180)*(60+theta1));
     writePosition(servo2,(1/180)*(67+theta2));
     
     
   %if the ball get stuck in a position, 35 away from the center then we try to get the ball
   %to the center.  
     if abs(x_coordinates(end-1)-x_coordinates(end))<=0.5 & distance >= 35 
     theta1=(38/210)*distance_x;
     theta2=(38/210)*distance_y;
     writePosition(servo1,(1/180)*(64+theta1));
     writePosition(servo2,(1/180)*(71+theta2));
    
     end 

end