function [A,d,B,e,c,b,f,D,K,g,F,G,h,j,L,H,I,Y] = array_0807()
%% 改动数值
CO2_max=65;     
lambda_co2=160; 

%% 上下限
Pda_max=200; 
Prt_max=200; 
p_g_max=300;
p_g_min=150;

% %
% eta=0.95;    
% ES_max=180;
% ES_min=40;
% ES0=100;

%
Phes_max=50;       
Qs_capacity=50000;
Qs_max=45000;      
Qs_min=5000;      
Qs_0=25000;        

eta_e=0.75;      
eta_f=0.65;        
eta_s=0.95;        
rho_H2=230;       
rho_FC=295;       

%% 成本
% a=246.4;
KS=100;
lambda_rt_b=200;
lambda_rt_s=300;
K_BAT=350;
K_EV=80;
Tcut_max=8;       
K_cut=250;        
K_trans=150;      

%火电煤耗系数线性化后参数
fcoal_150=42554.8;
fcoal_200=55387.2;
fcoal_250=68366;
fcoal_300=81491.2;
%碳排放系数线性化后参数
fco2_150=138.44125;
fco2_200=181.03;
fco2_250=224.10125;
fco2_300=267.655;
%碳交易相关参数
K_co2=0.7973; 
mn=0.6979; 
%HES
K_FC=80;         
K_H2=22;          

%% 电价数据
%%%%  时刻          2         4        6         8         10        12        14        16        18        20        22        24
%price_net = 0.9*[380; 380; 380; 380; 380; 610; 610; 880; 880; 880; 610; 610; 610; 610; 610; 880; 880; 880; 880; 880; 610; 610; 380; 380];
load '电力市场价格.mat'
price_net = 0.85*price_net;
% price_int = 0.75*[340; 310; 240; 340; 280; 360; 360; 620; 620; 620; 380; 380; 380; 390; 400; 620; 620; 620; 620; 620; 550; 410; 380; 390];
K_IC = 0.5*price_net;
%% 柔性负荷数据
cut =       [0;   0;   0;   0;   0;   10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;   0];
% trans_in =  [0;    0;   0;   0;   0;   0;   0;   10;  10;  10;   0;   0;   0;   0;   0;  10;  10;  10;  10;  10;  10;  10;   0;   0];
% trans_out = [10;   10;  10;  10;  10;  10;  0;   0;   0;    0;   0;  10;  10;  10;  10;   0;   0;   0;   0;   0;   0;   0;   0;   0];
trans_in =  [0;    0;   0;   0;   10;   10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  0;   0];
trans_out = [0;    0;   0;   0;   10;   10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  10;  0;   0];

%% 电动汽车数据
load '电动汽车数据.mat'
EVc = EV(:,1);   
EVd = EV(:,2); 
 
global P_w0
global P_pv0
global P_l0

%% 矩阵简写
E{1} = eye(24);
Z{1} = zeros(24);        Z{2} = zeros(24,48);     Z{3} = zeros(24,72);     Z{4} = zeros(24,96);     Z{5} = zeros(24,120);
Z{6} = zeros(24,144);    Z{7} = zeros(24,168);    Z{8} = zeros(24,192);    Z{9} = zeros(24,216);    Z{10} = zeros(24,240);
Z{11} = zeros(24,264);   Z{12} = zeros(24,288);   Z{13} = zeros(24,312);   Z{14} = zeros(24,336);   Z{15} = zeros(24,360);  
Z{16} = zeros(24,384);   Z{17} = zeros(24,408);
O{1} = ones(24);         O1{1} = ones(1,24);      ZO1{1} = zeros(1,24);

%% 构建矩阵
A=[ Z{6}  -E{1}  Z{11};
    Z{6}   E{1}  Z{11};
    Z{3}   Pda_max.*E{1}   -E{1}   Z{13};
    Z{3}  -Pda_max.*E{1}    Z{1}  -E{1}  Z{12};
    zeros(1,168)  -cut'./10   zeros(1,240);
    
    Z{10}   E{1}   Z{2}   -E{1}   Z{4};
    Z{10}   E{1}   E{1}    Z{2}  -E{1}   Z{3};
    Z{11}   E{1}   E{1}    Z{2}  -E{1}   Z{2};
    Z{12}   E{1}   Z{3}   -E{1}   Z{1}];

d=[-p_g_max*ones(24,1);
    p_g_min*ones(24,1);
    0*ones(24,1);
   -Pda_max*ones(24,1);
   -Tcut_max;
    0*ones(24,1);
    0*ones(24,1);
    0*ones(24,1);
    0*ones(24,1)];

%% 
B=[Z{4}   E{1}  -E{1}   E{1}   Z{11};
   Z{10}  E{1}   E{1}   E{1}   Z{5};
   Z{13}  E{1}   E{1}   E{1}   E{1}   Z{1};
   Z{6}  -E{1}   Z{6}   150*E{1}  200*E{1}  250*E{1}  300*E{1}  Z{1};
   Z{4}   mn*E{1}   Z{1}   -K_co2*E{1}   Z{6}   fco2_150*E{1}  fco2_200*E{1}   fco2_250*E{1}  fco2_300*E{1}   -E{1}];

e=[(-P_w0-P_pv0+P_l0)';
    ones(24,1);
    ones(24,1);
    0*ones(24,1);
    0*ones(24,1)];

%%
D=[ (rho_FC/eta_f/eta_s)*tril(O{1},0)   -(eta_e*rho_H2)*tril(O{1},0)   Z{8};
   -(rho_FC/eta_f/eta_s)*tril(O{1},0)    (eta_e*rho_H2)*tril(O{1},0)   Z{8};
    Z{4}   -E{1}    Z{5};
    Z{5}   -E{1}    Z{4}];

f=[-(Qs_max-Qs_0)*ones(24,1);
    (Qs_min-Qs_0)*ones(24,1);
   -Prt_max*ones(24,1);
   -Prt_max*ones(24,1)];

% D=[ (1/eta).*tril(O{1},0)   -(eta).*tril(O{1},0)   Z{8};
%    -(1/eta).*tril(O{1},0)    (eta).*tril(O{1},0)   Z{8};
%     Z{4}   -E{1}    Z{5};
%     Z{5}   -E{1}    Z{4}];
% 
% f=[-(ES_max-ES0)*ones(24,1);
%     (ES_min-ES0)*ones(24,1);
%    -Prt_max*ones(24,1);
%    -Prt_max*ones(24,1)];


%% 
K=[ (rho_FC/eta_f/eta_s)*ones(1,24)   -(eta_e*rho_H2)*ones(1,24)   zeros(1,192);
    zeros(1,168)     ones(1,24)  -ones(1,24)    zeros(1,24)];

% K=[ (1/eta)*ones(1,24)   -(eta)*ones(1,24)    zeros(1,192);
%     zeros(1,168)     ones(1,24)  -ones(1,24)    zeros(1,24)];
g= [0;0];

%%
F=[ Z{1}   diag(EVd)  Z{16};
    Z{1}  -diag(EVc)  Z{16};
    Phes_max*E{1}     Z{17};
   -Phes_max*E{1}     Z{17};
    Z{2}   Prt_max*E{1}     Z{15};
    Z{2}  -Prt_max*E{1}     Z{15};
    Z{7}   diag(cut)        Z{10};
    Z{8}   diag(trans_in)   Z{9};
    Z{9}   diag(trans_out)  Z{8};
    Z{17}  -E{1}];

G=[ Z{2}   -E{1}   Z{7};
    Z{3}   -E{1}   Z{6};
   -E{1}    Z{9};
    Z{1}   -E{1}   Z{8};   
    Z{4}   -E{1}   Z{5};
    Z{5}   -E{1}   Z{4};
    Z{6}   -E{1}   Z{3};
    Z{7}   -E{1}   Z{2};
    Z{8}   -E{1}   Z{1};
    Z{9}    -E{1}];

h=[ 0*ones(24,1);
   -EVc;
    0*ones(24,1);
   -Phes_max*ones(24,1);
    0*ones(24,1);
   -Prt_max*ones(24,1);
    0*ones(24,1);
    0*ones(24,1);
    0*ones(24,1);
   -CO2_max*ones(24,1)];

%%
L=[E{1}  -E{1}  E{1}  -E{1}  E{1}  -E{1}  E{1}  -E{1}  E{1}  Z{1}];
Y=[E{1}  E{1} -E{1}];
j=[P_w0+P_pv0-P_l0]';

%% 
H=[Z{4}  mn*E{1}  Z{1}   -K_co2*E{1}   Z{6}  fco2_150*E{1}  fco2_200*E{1}   fco2_250*E{1}  fco2_300*E{1}  -E{1}];
I=[Z{4}  mn*E{1}  Z{4}   -E{1}];

%% 目标函数矩阵
c=[zeros(1,96),  price_net',    -price_net',   zeros(1,168),  fcoal_150.*O1{1},  fcoal_200.*O1{1},  fcoal_250.*O1{1},  fcoal_300.*O1{1},  lambda_co2.*O1{1}];
b=[(K_FC/eta_f).*O1{1}, (K_H2*eta_e).*O1{1}, (K_EV+K_BAT).*O1{1}+K_IC',  K_EV.*O1{1},   lambda_rt_b+price_net',  lambda_rt_s-price_net', K_cut*O1{1}+price_net', K_trans*O1{1}-price_net', O1{1}+price_net', lambda_co2*O1{1}];

% b=[(KS/eta).*O1{1}, (KS*eta).*O1{1}, (K_EV+K_BAT).*O1{1},  K_EV.*O1{1},   lambda_rt_b+price_net',  lambda_rt_s-price_net', K_cut*O1{1}, K_trans*O1{1}-price_int', O1{1}+price_int', lambda_co2*O1{1}];
