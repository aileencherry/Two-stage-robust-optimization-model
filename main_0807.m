clc
clear
close all
warning off
tic
lambda_co2=160; 
%% 
load 风电预测出力.mat
load 光伏预测出力.mat
load 负荷预测值.mat
load Dw_up.mat
load Dw_down.mat
load Dpv_up.mat
load Dpv_down.mat
global P_w0
global P_pv0
global P_l0
global u0
global Dw_up
global Dw_down
global Dpv_up
global Dpv_down
global Dl_max

q_w=1.334;
q_pv=1;

P_w0 = q_w*P_wind_predict';
Dw_up = q_w*Dw_up;
Dw_down = q_w*Dw_down;

% P_w0 = P_wind_predict';

P_pv0 = q_pv*P_pv_predict';
Dpv_up=q_pv*Dpv_up;
Dpv_down=q_pv*Dpv_down;

P_l0 = 1.3*P_l_predict';
Dl_max=0.1 * P_l0;

T=24;
u0=[P_w0,P_pv0,P_l0]';
D_up=[Dw_up,Dpv_up,Dl_max'];
D_down=[Dw_down,Dpv_down,Dl_max'];

%% 
%
[x,LB,y] = MP(u0);
[u,UB] = SP(x);
UB1 = UB;
p(1)= UB - LB;  lb(1) = LB;   ub(1) = UB;
%
for k=1:5
    [x,LB,y] = MP(u);
    [u,UB] = SP(x);
    UB1 = min(UB1,UB);
    p(k+1) = UB1-LB;    
end
toc

% 
figure(2);
plot(p(1:6))
xlabel('迭代次数')
ylabel('UB-LB')
title('运行曲线') 

%% 
figure_0807(u,u0,x,y,D_up,D_down)

%% 
[A,d,B,e,c,b,f,D,K,g,F,G,h,j,L,H,I,Y] = array_0807();
load '电力市场价格.mat'
price_net = 0.85*price_net;
stage1=P_l0*price_net-c*x;
stage2=-b*y;
totalcost=stage1+stage2;
carbon_emmition=sum(x(409:432)+y(217:240)+0.7973*x(145:168));
carbon_cost=sum(lambda_co2.*(x(409:432)+y(217:240)));

%%  
function [x, LB, y] = MP(u)
P_g=sdpvar(1,24,'full');
P_ch=sdpvar(1,24,'full');
P_dis=sdpvar(1,24,'full');
V_hes=binvar(1,24,'full');
Pda_b=sdpvar(1,24,'full');
Pda_s=sdpvar(1,24,'full');
V_da=binvar(1,24,'full');
V_rt=binvar(1,24,'full');
V_ev=binvar(1,24,'full');
EV_dis=sdpvar(1,24,'full');
EV_ch=sdpvar(1,24,'full');
Prt_b=sdpvar(1,24,'full');
Prt_s=sdpvar(1,24,'full');
V_cut=binvar(1,24,'full');
V_in=binvar(1,24,'full');
V_out=binvar(1,24,'full');
Pcut=sdpvar(1,24,'full');  
P_in=sdpvar(1,24,'full');  
P_out=sdpvar(1,24,'full'); 
Dco2_1=sdpvar(1,24,'full'); 
Dco2_2=sdpvar(1,24,'full'); 


z1=binvar(1,24,'full'); 
z2=binvar(1,24,'full'); 
z3=binvar(1,24,'full'); 
w1=sdpvar(1,24,'full'); 
w2=sdpvar(1,24,'full'); 
w3=sdpvar(1,24,'full'); 
w4=sdpvar(1,24,'full'); 


afa=sdpvar(1,1,'full');
x=[V_hes,V_ev,V_rt,V_da,Pda_b,Pda_s,P_g,V_cut,V_in,V_out,z1,z2,z3,w1,w2,w3,w4,Dco2_1]';
y=[P_dis,P_ch,EV_dis,EV_ch,Prt_b,Prt_s,Pcut,P_in,P_out,Dco2_2]';

[A,d,B,e,c,b,f,D,K,g,F,G,h,j,L,H,I,Y] = array_0807();

%%
C=[x>=0];
C=C+[y>=0];
C=C+[A*x>=d];
C=C+[B*x==e];
C=C+[D*y>=f];
C=C+[K*y==g];
C=C+[F*x+G*y>=h];
C=C+[L*y+Y*u==j];
C=C+[H*x+I*y==0];
C=C+[afa>=b*y];

%%
Fj=c*x+afa;
ops = sdpsettings('solver','cplex');
result = optimize(C,Fj,ops);
x=value(x);
y=value(y);
LB=value(afa);
end
 

%% 
function [u,UB] = SP(x)
%%  
global P_w0
global P_pv0
global P_l0
global u0
% global Dw_max
% global Dpv_max
global Dl_max
global Dw_up
global Dw_down
global Dpv_up
global Dpv_down
[A,d,B,e,c,b,f,D,K,g,F,G,h,j,L,H,I,Y] = array_0807();

%% 
W1=sdpvar(96,1,'full');
W2=sdpvar(2,1,'full');
W3=sdpvar(240,1,'full');
W4=sdpvar(24,1,'full');
W5=sdpvar(24,1,'full');


BB_1=sdpvar(24,1);        BB_2=sdpvar(24,1);     
BB_3=sdpvar(24,1);        BB_4=sdpvar(24,1);    
BB_5=sdpvar(24,1);        BB_6=sdpvar(24,1);    


%
BPV_down=binvar(24,1,'full');  BPV_up=binvar(24,1,'full');
BL_up=binvar(24,1,'full');     BL_down=binvar(24,1,'full');
BW_down=binvar(24,1,'full');   BW_up=binvar(24,1,'full');


%
C=[sum(BPV_down)+sum(BPV_up)<=3, sum(BL_up)+sum(BL_down)<=3, sum(BW_down)+sum(BW_up)<=3];

%
MM=100000;
C=C+[0<=BB_1,BB_1<=MM*BPV_down];           C=C+[0<=BB_3,BB_3<=MM*BPV_up];
C=C+[W4-MM*(1-BPV_down)<=BB_1,BB_1<=W4];   C=C+[W4-MM*(1-BPV_up)<=BB_3,BB_3<=W4];
C=C+[0<=BB_2,BB_2<=MM*BL_up];              C=C+[0<=BB_4,BB_4<=MM*BL_down];
C=C+[W4-MM*(1-BL_up)<=BB_2,BB_2<=W4];      C=C+[W4-MM*(1-BL_down)<=BB_4,BB_4<=W4];


C=C+[0<=BB_5,BB_5<=MM*BW_down];            C=C+[0<=BB_6,BB_6<=MM*BW_up];
C=C+[W4-MM*(1-BW_down)<=BB_5,BB_5<=W4];   C=C+[W4-MM*(1-BW_up)<=BB_6,BB_6<=W4];

for i=1:24
    BW_up(i)+BW_down(i)<=1;
    BPV_up(i)+BPV_down(i)<=1;
    BL_up(i)+BL_down(i)<=1;
end
%% 进行求解
C=C+[D'*W1+K'*W2+G'*W3+L'*W4+I'*W5<=b'];
C=C+[W1>=0,W3>=0];
Fj=-(f'*W1+g'*W2+(h-F*x)'*W3+j'*W4-(Y*u0)'*W4 -(H*x)'*W5 + Dpv_down'*BB_1 + Dl_max*BB_2 - Dpv_up'*BB_3 - Dl_max*BB_4  + Dw_down'*BB_5 - Dw_up'*BB_6);
ops = sdpsettings('solver','cplex');
result = optimize(C,Fj,ops);
UB=value(-Fj);

result_W4=value(W4)
BW_up=value(BW_up);
BW_down=value(BW_down);
BPV_up=value(BPV_up);
BPV_down=value(BPV_down);
BL_up=value(BL_up);
BL_down=value(BL_down);

%%
P_w=P_w0 - BW_down'.*Dw_down' + BW_up'.*Dw_up';
P_pv=P_pv0 - BPV_down'.*Dpv_down' + BPV_up'.*Dpv_up';
P_l=P_l0 + BL_up'.*Dl_max - BL_down'.*Dl_max;
u=[P_w,P_pv,P_l]';

figure(1)
plot(BW_up-BW_down,'g','linewidth',3)
hold on
plot(BPV_up-BPV_down,'r','linewidth',3)
hold on
plot(BL_up-BL_down,'b','linewidth',3)
hold off
legend('wind','pv','load')
xlim([1,24]); set(gca,'xTick',0:2:24);
grid on
end