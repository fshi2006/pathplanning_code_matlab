%***************************************
%Author: Chenglong Qian
%Date: 2019-11-5
%***************************************
%% ���̳�ʼ��
clear all; close all;
x_I=1; y_I=1;           % ���ó�ʼ��
x_G=700; y_G=700;       % ����Ŀ���
goal(1)=x_G;
goal(2)=y_G;
Thr=50;                 %����Ŀ�����ֵ ���������Χ��ʱ����Ϊ�ѵ���Ŀ���
Delta= 30;              % ������չ��������չ��������������
%% ������ʼ��
T.v(1).x = x_I;         % T������Ҫ��������v�ǽڵ㣬�����Ȱ���ʼ����뵽T������
T.v(1).y = y_I; 
T.v(1).xPrev = x_I;     % ��ʼ�ڵ�ĸ��ڵ���Ȼ���䱾��
T.v(1).yPrev = y_I;
T.v(1).dist=0;          %�Ӹ��ڵ㵽�ýڵ�ľ��룬�����ȡŷ�Ͼ���
T.v(1).indPrev = 0;     %���ڵ������
%% ��ʼ������������ҵ����
figure(1);
ImpRgb=imread('newmap.png');  
Imp=rgb2gray(ImpRgb);
imshow(Imp)
xL=size(Imp,1);%��ͼx�᳤��
yL=size(Imp,2);%��ͼy�᳤��
hold on
plot(x_I, y_I, 'ro', 'MarkerSize',10, 'MarkerFaceColor','r');
plot(x_G, y_G, 'go', 'MarkerSize',10, 'MarkerFaceColor','g');% ��������Ŀ���
count=1;
for iter = 1:3000
%     x_rand=[];
    %Step 1: �ڵ�ͼ���������һ����x_rand
    %��ʾ���ã�x_rand(1),x_rand(2)����ʾ�����в����������
    x_rand=Sample(Imp,goal);
%     x_near=[];
    %Step 2: ���������������ҵ�����ڽ���x_near 
    %��ʾ��x_near�Ѿ�����T��
    [x_near,index]= Near(x_rand,T);
    plot(x_near(1), x_near(2), 'go', 'MarkerSize',2);
%     x_new=[];
    %Step 3: ��չ�õ�x_new�ڵ�
    %��ʾ��ע��ʹ����չ����Delta
    x_new=Steer(x_rand,x_near,Delta);
    %���ڵ��Ƿ���collision-free
    if ~collisionChecking(x_near,x_new,Imp) %������ϰ���������
       continue;
    end
    count=count+1;
    
    %Step 4: ��x_new������T 
    %��ʾ���½ڵ�x_new�ĸ��ڵ���x_near
    T.v(count).x = x_new(1);        
    T.v(count).y = x_new(2); 
    T.v(count).xPrev = x_near(1);     % ��ʼ�ڵ�ĸ��ڵ���Ȼ���䱾��
    T.v(count).yPrev = x_near(2);
    T.v(count).dist=Distance(x_new,x_near);          %�Ӹ��ڵ㵽�ýڵ�ľ��룬�����ȡŷ�Ͼ���
    T.v(count).indPrev = index;     %���ڵ������
    %Step 5:����Ƿ񵽴�Ŀ��㸽�� 
    %��ʾ��ע��ʹ��Ŀ�����ֵThr������ǰ�ڵ���յ��ŷʽ����С��Thr����������ǰforѭ��
    if Distance(x_new,goal) < Thr
        break;
    end
   %Step 6:��x_near��x_new֮���·��������
   %��ʾ 1��ʹ��plot���ƣ���ΪҪ�����ͬһ��ͼ�ϻ����߶Σ�����ÿ��ʹ��plot����Ҫ����hold on����
   %��ʾ 2�����ж��յ���������forѭ��ǰ���ǵð�x_near��x_new֮���·��������
%    plot([x_near(1),x_near(2)],[x_new(1),x_new(2)]);
%    hold on
  line([x_near(1),x_new(1)],[x_near(2),x_new(2)]);
   pause(0.1); %��ͣ0.1s��ʹ��RRT��չ�������׹۲�
end
%% ·���Ѿ��ҵ��������ѯ
if iter < 2000
    path.pos(1).x = x_G; path.pos(1).y = y_G;
    path.pos(2).x = T.v(end).x; path.pos(2).y = T.v(end).y;
    pathIndex = T.v(end).indPrev; % �յ����·��
    j=0;
    while 1
        path.pos(j+3).x = T.v(pathIndex).x;
        path.pos(j+3).y = T.v(pathIndex).y;
        pathIndex = T.v(pathIndex).indPrev;
        if pathIndex == 1
            break
        end
        j=j+1;
    end  % ���յ���ݵ����
    path.pos(end+1).x = x_I; path.pos(end).y = y_I; % ������·��
    for j = 2:length(path.pos)
        plot([path.pos(j).x; path.pos(j-1).x;], [path.pos(j).y; path.pos(j-1).y], 'b', 'Linewidth', 3);
    end
else
    disp('Error, no path found!');
end

function X_rand=Sample(map,goal)
% if rand<0.5
%     X_rand = rand(1,2) .* size(map);   % random sample
% else 
%     X_rand=goal;
% end

if unifrnd(0,1)<0.5
   X_rand(1)= unifrnd(0,1)* size(map,1);   % ���Ȳ���
   X_rand(2)= unifrnd(0,1)* size(map,2);   % random sample
else
   X_rand=goal;
end
end

function X_new=Steer(X_rand,X_near,StepSize)
theta = atan2(X_rand(1)-X_near(1),X_rand(2)-X_near(2));  % direction to extend sample to produce new node
X_new = X_near(1:2) + StepSize * [sin(theta)  cos(theta)];
end

function [X_near,index]=Near(X_rand,T)
min_distance=sqrt((X_rand(1)-T.v(1).x)^2+(X_rand(2)-T.v(1).y)^2);
for T_iter=1:size(T.v,2)
    temp_distance=sqrt((X_rand(1)-T.v(T_iter).x)^2+(X_rand(2)-T.v(T_iter).y)^2);
    if temp_distance<=min_distance
        min_distance=temp_distance;
        X_near(1)=T.v(T_iter).x
        X_near(2)=T.v(T_iter).y
        index=T_iter;
    end
end
end

function distance=Distance(start_Pt,goal_Pt)
distance=sqrt((start_Pt(1)-goal_Pt(1))^2+(start_Pt(2)-goal_Pt(2))^2);
end