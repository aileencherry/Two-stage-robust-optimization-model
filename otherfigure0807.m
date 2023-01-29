%% 其他相关图片
clc;clear;close all
%% 数据
load 电力市场价格.mat
load 风电预测出力.mat
load 光伏预测出力.mat
load 负荷预测值.mat
load 风电场景.mat
load 光伏场景.mat
load Dw_up.mat
load Dw_down.mat
load Dpv_up.mat
load Dpv_down.mat
q_w=1.334;
q_PV=1;

P_w0 = q_w*P_wind_predict;
wind_scenarios = q_w*wind_scenarios;
Dw_up = q_w*Dw_up;
Dw_down = q_w*Dw_down;

P_pv0 = 1*P_pv_predict;

P_l0 = 1.3*P_l_predict;

%% 
%%%%  时刻          2         4        6         8         10        12        14        16        18        20        22        24
%price_net = 0.9*[380; 380; 380; 380; 380; 610; 610; 880; 880; 880; 610; 610; 610; 610; 610; 880; 880; 880; 880; 880; 610; 610; 380; 380];
price_net = 0.85*price_net;


%% 
figure(1);
plot(P_w0,'linewidth',2,'marker','.','markersize',12)
hold on
plot(P_pv0,'linewidth',2,'marker','.','markersize',12)
hold on
plot(P_l0,'linewidth',2,'marker','.','markersize',12)
le=legend({'Wind power',' Photovoltaic','Load'});
legend('FontName','Times New Roman')
xlim([1,24]); ylim([0,450])
grid on
set(gca,'xTick',0:4:24); set(gca,'yTick',0:50:450);
set(gca,'FontSize',18);
set(gcf,'Position',[200,200,600,350]);
xlabel('Time/h','FontName','Times New Roman');
ylabel('Power/MW','FontName','Times New Roman');
set(le,'Box','off');


%% 场景集与上下界
%风电
figure()
set(gcf,'Position',[600,500,500,300]);
p1=plot(wind_scenarios);
hold on
p2=plot(P_w0+Dw_up,'k--','linewidth',1.5);
hold on
p3=plot(P_w0-Dw_down,'k--','linewidth',1.5);
grid on
le=legend([p1(1) p2],{'Scenarios','Upper and lower bounds'});
legend('Location','northoutside','Orientation','horizontal','FontName','Times New Roman','FontSize',14)
xlim([1,24]); set(gca,'xTick',0:4:24);
ylim([0,200]); set(gca,'yTick',0:50:200);
xlabel('Time/h','FontName','Times New Roman');
ylabel('Power/MW','FontName','Times New Roman');
set(gca,'FontSize',14);
set(le,'Box','off');

%光伏
figure()
set(gcf,'Position',[600,500,500,300]);
p1=plot(pv_scenarios);
hold on
p2=plot(P_pv0+Dpv_up,'k--','linewidth',1.5);
hold on
p3=plot(P_pv0-Dpv_down,'k--','linewidth',1.5);
grid on
le=legend([p1(1) p2],{'Scenarios','Upper and lower bounds'});
legend('Location','northoutside','Orientation','horizontal','FontName','Times New Roman','FontSize',14)
xlim([1,24]); set(gca,'xTick',0:4:24);
ylim([0,90]); set(gca,'yTick',0:20:80);
xlabel('Time/h','FontName','Times New Roman');
ylabel('Power/MW','FontName','Times New Roman');
set(gca,'FontSize',14);
set(le,'Box','off');

%% 电力市场价格
figure();
T=1:24;
T1=1/3600:1/3600:24;
price_net_all=interp1(T,price_net,T1,'nearest');
set(gcf,'Position',[600,500,600,350]);
plot(T1,price_net_all,'linewidth',2)
xlim([1,24]); set(gca,'xTick',0:2:24);
ylim([0,700]); set(gca,'yTick',0:100:700);
grid on
xlabel('Time/h','FontName','Times New Roman')
ylabel('Electricuty price/¥','FontName','Times New Roman')
set(gca,'FontSize',14);

%% 碳交易案例分析
figure()
set(gcf,'Position',[600,500,1100,500]);
subplot(1,3,1)
carbon_price =[140, 150, 160, 170, 180, 190, 200, 210];
emission_60=[5936.7, 5857.7, 5752.3, 5752.3, 5752.3, 5752.3, 5740.3, 5733.4];
emission_70=[5898.1, 5872.7, 5767.3, 5767.3, 5767.3, 5767.3, 5760.3, 5753.4];
emission_80=[5862.8, 5862.8, 5787.3, 5787.3, 5787.3, 5787.3, 5780.3, 5773.4];
p1=plot(carbon_price,emission_60,'linewidth',1.5,'marker','*','markersize',4);
hold on
p2=plot(carbon_price,emission_70,'linewidth',1.5,'marker','*','markersize',4);
hold on
p3=plot(carbon_price,emission_80,'linewidth',1.5,'marker','*','markersize',4);
le=legend([p1 p2 p3],{'Carbon Emission Quota = 60','Carbon Emission Quota = 70','Carbon Emission Quota = 80'},'FontName','Times New Roman','FontSize',14);
legend('Location','northoutside','Orientation','horizontal','FontName','Times New Roman','FontSize',14)
xlabel('Carbon trading prices/(¥·ton^{-1})','FontName','Times New Roman','FontSize',14)
ylabel('Carbon emission/ton','FontName','Times New Roman','FontSize',14)
xlim([140,210]); set(gca,'xTick',140:10:210);
set(gca,'FontSize',14);
set(le,'Box','off');

subplot(1,3,2)
carbon_cost_60=[127430	124680	125510	130170	137820	145480	150740	156810];
carbon_cost_70=[122030	126930	124910	132720	140520	148330	154740	161010];
carbon_cost_80=[117080	125440	128110	136120	144120	152130	158740	165210];
p1=plot(carbon_price,carbon_cost_60,'linewidth',1.5,'marker','*','markersize',4);
hold on
p2=plot(carbon_price,carbon_cost_70,'linewidth',1.5,'marker','*','markersize',4);
hold on
p3=plot(carbon_price,carbon_cost_80,'linewidth',1.5,'marker','*','markersize',4);
% le=legend([p1 p2 p3],{'Carbon Emission Quota = 60','Carbon Emission Quota = 70','Carbon Emission Quota = 80'},'FontName','Times New Roman','FontSize',14);
xlabel('Carbon trading prices/(¥·ton^{-1})','FontName','Times New Roman','FontSize',14)
ylabel('Carbon trading cost/¥','FontName','Times New Roman','FontSize',14)
xlim([140,210]); set(gca,'xTick',140:10:210);
set(gca,'FontSize',14);

subplot(1,3,3)
total_cost_60=[1791100	1773900	1765900	1758200	1750500	1742900	1735300	1727800];
total_cost_70=[1809400	1800800	1792600	1784800	1777000	1769100	1761400	1753700];
total_cost_80=[1835100	1826700	1818500	1810400	1802400	1794400	1786500	1778600];
p1=plot(carbon_price,total_cost_60,'linewidth',1.5,'marker','*','markersize',4);
hold on
p2=plot(carbon_price,total_cost_70,'linewidth',1.5,'marker','*','markersize',4);
hold on
p3=plot(carbon_price,total_cost_80,'linewidth',1.5,'marker','*','markersize',4);
% le=legend([p1 p2 p3],{'Carbon Emission Quota = 60','Carbon Emission Quota = 70','Carbon Emission Quota = 80'},'FontName','Times New Roman','FontSize',14);
xlabel('Carbon trading prices/(¥·ton^{-1})','FontName','Times New Roman','FontSize',14)
ylabel('Total cost/¥','FontName','Times New Roman','FontSize',14)
xlim([140,210]); set(gca,'xTick',140:10:210);
set(gca,'FontSize',14);

%%
figure()
Quota=[55	60	65	70	75];
emission=[5714.2	5752.3	5757.3	5767.3	5777.3];
tradingcost=[120520	122510	123310	124910	126510];
totalcost=[1748700	1765900	1779500	1792600	1805600];
costpig=[5718.7	5735.9	5749.5	5762.6	5775.6];
%[5710:5780]
p1=plot(Quota,emission,'linewidth',1.5,'marker','*','markersize',4);
hold on
% p2=plot(Quota,tradingcost,'linewidth',1.5,'marker','*','markersize',4);
% hold on
p3=plot(Quota,costpig,'linewidth',1.5,'marker','*','markersize',4);
le=legend([p1 p3],{'Carbon emission','Totalcost'},'FontName','Times New Roman','FontSize',14);
xlabel('Carbon trading prices/(¥·ton^{-1})','FontName','Times New Roman','FontSize',14)
ylabel('Carbon trading cost/¥','FontName','Times New Roman','FontSize',14)
xlim([55,75]); set(gca,'xTick',55:5:75);
ylim([5710,5780]);
% ylim([1740000,1810000]); 
% set(gca,'xTick',140:10:210);
set(gca,'FontSize',14);





