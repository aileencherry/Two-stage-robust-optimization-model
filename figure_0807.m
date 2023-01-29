function [] = figure_0807(u,u0,x,y,D_up,D_down)
%% 数据
P_w = u(1:24);     P_pv = u(25:48);    P_l = u(49:72);
P_w0 = u0(1:24);   P_pv0 = u0(25:48);  P_l0 = u0(49:72);

Dw_up = D_up(:,1); Dpv_up = D_up(:,2); Dl_up = D_up(:,3);
Dw_down = D_down(:,1); Dpv_down = D_down(:,2); Dl_down= D_down(:,3);

%x=[V_hes,V_ev,V_rt,V_da,Pda_b,Pda_s,P_g]';
x=value(x);
Pda_b=x(97:120);
Pda_s=x(121:144);
P_g=x(145:168);
%y=[P_dis,P_ch,EV_dis,EV_ch,Prt_b,Prt_s]';
y=value(y);
P_dis=y(1:24);
P_ch=y(25:48);
EV_dis=y(49:72);
EV_ch=y(73:96);
Prt_b=y(97:120);
Prt_s=y(121:144);
Pcut=y(145:168);
P_in=y(169:192);
P_out=y(193:216);


%% 最恶劣场景曲线
figure(4)
set(gcf,'Position',[400,200,600,700]);

subplot(3,1,1)
p1=plot(P_w,'k','linewidth',3);
hold on
p2=plot(P_w0,'r.--','linewidth',1);
hold on
p3=plot(P_w0+Dw_up,'b--','linewidth',1);
hold on
plot(P_w0-Dw_down,'b--','linewidth',1)
hold off
xlim([1,24]); ylim([0,250])
grid on
set(gca,'xTick',0:4:24);  set(gca,'yTick',0:50:250);
set(gca,'FontSize',16);
xlabel('Time/h','FontName','Times New Roman');
ylabel('Power/MW','FontName','Times New Roman');
legend([p1 p2 p3],{'Worst scenario','Predicted value','Upper and lower boundaries'})
legend('Location','northoutside','Orientation','horizontal')
legend('FontName','Times New Roman')

subplot(3,1,2)
plot(P_pv,'k','linewidth',3)
hold on
plot(P_pv0,'r.--','linewidth',1)
hold on
plot(P_pv0+Dpv_up,'b--','linewidth',1)
hold on
plot(P_pv0-Dpv_down,'b--','linewidth',1)
hold off
xlim([1,24]); ylim([0,100])
grid on
set(gca,'xTick',0:4:24);  set(gca,'yTick',0:20:100);
set(gca,'FontSize',16);
xlabel('Time/h','FontName','Times New Roman');
ylabel('Power/MW','FontName','Times New Roman');

subplot(3,1,3)
plot(P_l,'k','linewidth',3)
hold on
plot(P_l0,'r.--','linewidth',1)
hold on
plot(P_l0+Dl_up,'b--','linewidth',1)
hold on
plot(P_l0-Dl_down,'b--','linewidth',1)
hold off 
xlim([1,24]); ylim([0,500])
grid on
set(gca,'xTick',0:4:24);  set(gca,'yTick',0:100:500);
set(gca,'FontSize',16);
xlabel('Time/h','FontName','Times New Roman');
ylabel('Power/MW','FontName','Times New Roman');


%% 调度柱状图
figure(5)
set(gcf,'Position',[200,200,650,350]);
step1=[Pda_b';-Pda_s';P_g']';
b=bar(step1,0.5,'stacked');
b(1).FaceColor = '#D95319';
b(2).FaceColor = '#0072BD';
b(3).FaceColor = '#EDB120';
le=legend({'Electricity purchase','Electricity sales','CPP'});
xlim([0,25]); set(gca,'xTick',0:4:24);
ylim([-250,350]);set(gca,'yTick',-200:50:300);
xlabel('Time/h','FontName','Times New Roman')
ylabel('Power/MW','FontName','Times New Roman')
legend('Location','northoutside','Orientation','horizontal')
legend('FontName','Times New Roman','FontSize',14)
set(gca,'FontSize',14);
set(le,'Box','off');

figure(6)
set(gcf,'Position',[1000,200,650,350]);
step2=[-P_ch,P_dis,EV_dis,-EV_ch,Prt_b,-Prt_s,Pcut,-P_in,P_out];
b=bar(step2,0.5,'stacked');
b(1).FaceColor = '#D67F7F';
b(2).FaceColor = '#F4DC76';
b(3).FaceColor = '#669966';
b(4).FaceColor = '#BFBFFF';
b(5).FaceColor = '#99CCFF';
b(6).FaceColor = [.2 .6 .5];
b(7).FaceColor = '#336699';
b(8).FaceColor = '#DF8E55';
b(9).FaceColor = '#DF8E55';
le=legend([b(1) b(2) b(3) b(4)  b(5) b(6) b(7) b(8)],...
    {'HES charging','HES discharging','EVVES discharging','EVVES charging',...
    'Electricity purchase','Electricity sales','IL','TL'});
xlim([0,25]); set(gca,'xTick',0:4:24);
xlabel('Time/h','FontName','Times New Roman')
ylabel('Power/MW','FontName','Times New Roman')
legend('Location','northoutside','FontName','Times New Roman','Orientation','horizontal','NumColumns',4)
set(gca,'FontSize',14);
set(le,'Box','off');
%% 碳交易
T=1:24;
T1=1/3600:1/3600:24;
D1=x(409:432);
D2=y(217:240);
D_co2=x(409:432)+y(217:240);
D_co2_all=interp1(T,D_co2,T1,'nearest');

figure(7)
set(gcf,'Position',[600,500,500,320]);
% plot(T1,D_co2_all,'linewidth',2)
b=bar([D1,D2],0.5,'stacked');
b(1).FaceColor = '#EDB120';
b(2).FaceColor = '#D95319';
xlim([0,25]); set(gca,'xTick',0:4:24);
ylim([0,80]); set(gca,'yTick',0:10:80);
le=legend({'Stage 1','Stage 2'});
legend('Location','northoutside','FontName','Times New Roman','Orientation','horizontal','NumColumns',4)
% grid on
xlabel('Time/h','FontName','Times New Roman')
ylabel('Carbon Emission Quota/ton','FontName','Times New Roman','FontSize',14)
set(gca,'FontSize',14);
set(le,'Box','off');
%% HES 等效SOC
SOC(1) = 0.5;
for i=1:24
    SOC(i+1) = SOC(i) + ( (0.75*230)*P_ch(i) - (295/0.95/0.65)*P_dis(i) )/50000;
%     SOC(i+1) = SOC(i) + ( (0.95)*P_ch(i) - (1/0.95)*P_dis(i) )/200;
end
T=1:25;
T1=1/3600:1/3600:25;
SOC_all=interp1(T,SOC,T1,'nearest');
SOC0=0.5*ones(1,25);
SOC_0=interp1(T,SOC0,T1,'nearest');
figure(8)
set(gcf,'Position',[600,500,500,275]);
plot(T1,SOC_0,'--','linewidth',0.5)
hold on
plot(T1,SOC_all,'linewidth',2)
grid on
xlim([1,24]); set(gca,'xTick',0:4:24);
ylim([0.1,0.9]); set(gca,'yTick',0.1:0.1:0.9);
xlabel('Time/h','FontName','Times New Roman')
ylabel('Equivalent SOC','FontName','Times New Roman')
set(gca,'FontSize',12);
% deltaQ = sum( (eta_e*rho_H2)*P_ch(:) ) - sum( (rho_FC/eta_f/eta_s)*P_dis(:) ) - sum( (eta_e*rho_H2)*HES_ch(:) );
