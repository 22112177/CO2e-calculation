clc;clear
tic
%搭建参数库

%不变量
disel_e = 33;%1L汽油含有33MJ能量
disel_c = 2.7;%1L汽油碳排放2.7kg CO2e
electricity_e = 3.6;%1度电能量3.6MJ
waste_fuel_e = [[28.38,13.27,8.02,9.9]];%塑料、纺织物、竹木、纸张"湿基"热值 MJ/kg
raw_material_c = [1.8,2.21,0.0345];%塑料、Fe回收、土原材料碳排放kgCO2e/kg；


%填埋场组分参数
waste_weight = 13882400;%吨
water_content = 0.57;
%湿基塑料、纺织物、竹木、纸张、金属、粗细颗粒土含量
waste_content_wet = [0.35,0.1,0.0298,0,0.0075,0.4498];
%干基塑料、纺织物、竹木、纸张、金属、粗细颗粒土含量
waste_content_dry = [0.3461,0.0871,0.0256,0,0.016,0.448];
%湿基组分含水率塑料、纺织物、竹木、纸张、金属、粗细颗粒土
waste_content_water = [0.05,0.3,0.4,0.45,0.01,0.3];
C_content = [[0.7,0.4,0.3,0.4];[0.67,0.38,0.5,0.46]];%塑料、纺织物、竹木、纸张碳含量




%开挖
excavate = [1.3,1.4,1.5];
excavate_b = 1.3;%开挖一吨垃圾油耗1.3-1.5L/t
excavate_v = 0.2;

%筛分
screen = [5.71,19.44,35];%开挖用电kWh/t
screen_b = 30;
screen_v = 10;
%筛分中轻质物中：塑料、纺织物、竹木、纸张；Fe提取效率
extraction_efficiency = [[0.75,0.9,0.9,0.9,0.9];[0.75,0.825,0.85,0.875,0.8];[0.75,0.75,0.8,0.85,0.7]];%中间的是我杜撰的

%燃烧
ef_CH4 = [0.2,6];%焚烧CH4排放因子,kg/t 6,60,188,237
ef_N2O = 170;%焚烧N2O排放因子,g/t 170

%运输
transport_c = [0.52,0.17,0.085];%kgCO2e/tkm
distance_Fe = [750,500,250];%km
distance_plastic = [750,500,250];%km
distance_incinerator = [150,100,50];%km
distance_coarse_soil = [150,100,50];%km
distance_fine_soil = [450,300,150];%km

%替代碳排放
Fe_cr = [1.57,0.94,0.38];%生产原材料铁碳排减去二次加工碳排kg CO2e/kg
plastic_cr = [2.62,1.53,0.49];%生产原材料塑料碳排减去二次加工碳排kg CO2e/kg
soil_cr = [5.58,1.74,0.85];%骨料开采碳排放kg CO2e/t
%替代原材料的程度，Fe
substitution_factor_Fe = [1,0.75,0.5];
electricity_cr = 0.58955;%一度电0.58955kgCO2e/kWh
heat_cr = [0.147,0.11,0.06];%[0.147,0.073,0.005][0.06,0.11];%kgCO2e/MJ

%能量转化效率
w2e = [0.15,0.3,0.4];%发电能量转化效率
heat = [0.38,0.65];%热利用能量转化效率


%计算

n=10^5;%运行次数
f=zeros(n,5); %运输、能量利用效率、原材料替代、高效节能筛分


for i =1:n

    S1=[1,2,3];
    S2=[1,2,3];
    S3=[1,2,3];
    S4=[1,2,3];

    s1=datasample(S1,1);
    s2=datasample(S2,1);
    s3=datasample(S3,1);
    s4=datasample(S4,1);

    f(i,2) = s1; 
    f(i,3) = s2;
    f(i,4) = s3;
    f(i,5) = s4;


    if s1 == 1
        t=1;
        transport_c_r = transport_c(t);
        distance_Fe_r = distance_Fe(t);
        distance_plastic_r = distance_plastic(t);
        distance_incinerator_r = distance_incinerator(t);
        distance_coarse_soil_r = distance_coarse_soil(t);
    elseif s1 ==2
        t=2;
        transport_c_r = transport_c(t);
        distance_Fe_r = distance_Fe(t);
        distance_plastic_r = distance_plastic(t);
        distance_incinerator_r = distance_incinerator(t);
        distance_coarse_soil_r = distance_coarse_soil(t);
    else
        t=3;
        transport_c_r = transport_c(t);
        distance_Fe_r = distance_Fe(t);
        distance_plastic_r = distance_plastic(t);
        distance_incinerator_r = distance_incinerator(t);
        distance_coarse_soil_r = distance_coarse_soil(t);
    end

    if s2 == 1 %40%
        w2e_r = datasample(w2e,1);
        heat_r = 0.41 - w2e_r;
    elseif s2 == 2 %60%
        w2e_r = datasample(w2e,1);
        heat_r = 0.6 - w2e_r;
    else %80%
        w2e_r = datasample(w2e,1);
        heat_r = 0.8 - w2e_r;
    end

    if s3 == 1
        t=3;
        Fe_cr_r = Fe_cr(t);
        soil_cr_r = soil_cr(t);
        heat_cr_r = heat_cr(t);
        substitution_factor_Fe_r = substitution_factor_Fe(t);
    elseif s3 == 2
        t=2;
        Fe_cr_r = Fe_cr(t);
        soil_cr_r = soil_cr(t);
        heat_cr_r = heat_cr(t);
        substitution_factor_Fe_r = substitution_factor_Fe(t);
    else
        t=1;
        Fe_cr_r = Fe_cr(t);
        soil_cr_r = soil_cr(t);
        heat_cr_r = heat_cr(t);
        substitution_factor_Fe_r = substitution_factor_Fe(t);
    end

    if s4 == 1
        extraction_efficiency_r = 3;
        screen_r = 3;
    elseif s4 == 2
        extraction_efficiency_r = 2;
        screen_r = 2;
    else
        extraction_efficiency_r = 1;
        screen_r = 1;
    end
    

    excavate_r = datasample(excavate,1);
%     screen_r = datasample(screen,1);
%     transport_c_r = datasample(transport_c,1);
%     distance_Fe_r = datasample(distance_Fe,1);
%     distance_plastic_r = datasample(distance_plastic,1);
%     distance_incinerator_r = datasample(distance_incinerator,1);
%     distance_coarse_soil_r = datasample(distance_coarse_soil,1);
    C_content_r = datasample([1,2],1);%各物质碳含量
%     Fe_cr_r = datasample(Fe_cr,1);
%     soil_cr_r = datasample(soil_cr,1);
%     heat_cr_r = datasample(heat_cr,1);
%     w2e_r = datasample(w2e,1);
%     heat_r = 0.8 - w2e_r;
    ef_CH4_r = datasample(ef_CH4,1);
    ef_N2O_r = ef_N2O;





    CE_excavate = waste_weight * excavate_r * disel_c;%挖掘碳排放kgCO2e

    CE_screen = waste_weight * screen_r * electricity_cr;%筛分用电碳排放kgCO2e

    waste_fuel_C = 0;%燃烧碳排放，轻质物干基*提取效率*含碳率
    for j = 1:4
        waste_fuel_C = waste_fuel_C + waste_content_dry(j) ...
            *extraction_efficiency(extraction_efficiency_r,j)*C_content(C_content_r,j);
    end
    CE_waste_fuel = waste_weight*(1-water_content) ...
        *waste_fuel_C*44/12;%单位吨，CO2排放
%这里考虑塑料燃烧
    waste_fuel = 0;
    for j = 1:4
        waste_fuel = waste_fuel + waste_content_dry(j) * extraction_efficiency(extraction_efficiency_r,j);%干基下轻质物含量
    end
    CE_waste_fuel = CE_waste_fuel + waste_weight *(1-water_content)* waste_fuel * ef_CH4_r * 28 * 0.001;%单位吨，CH4排放
    CE_waste_fuel = CE_waste_fuel + waste_weight * (1-water_content) * waste_content_dry(1)...
        * extraction_efficiency(extraction_efficiency_r,1) * ef_N2O_r * 298 * 0.001*0.001;%单位吨，N2O排放




    CE_T_Fe = waste_weight*waste_content_wet(5)*(1-waste_content_water(5)) ...
        *distance_Fe_r * transport_c_r;%单位kg CO2


    tp = 0;%临时参数，塑料、织物、竹木、纸张，湿基占比
    for j = 1:4
        tp = tp + waste_content_wet(j);
    end
    CE_T_incinerator = waste_weight * tp * distance_incinerator_r ...
        * transport_c_r;%单位kg CO2

    CE_T_soil = waste_weight * waste_content_wet(6) * distance_coarse_soil_r ...
        * transport_c_r;%单位kgCO2


    CR_Fe = waste_weight*waste_content_wet(5)*(1-waste_content_water(5)) ...
        * extraction_efficiency(extraction_efficiency_r,5) ...
        * substitution_factor_Fe_r ...
        *Fe_cr_r;%单位 吨CO2


    waste_fuel_MJ = 0;
    for j = 1:4
        waste_fuel_MJ = waste_fuel_MJ + waste_content_wet(j) ...
            *extraction_efficiency(extraction_efficiency_r,j) ...
            *waste_fuel_e(j);%MJ百分比,单位MJ/kg
    end
    CR_electricity = waste_weight * waste_fuel_MJ * 1000 *0.8* w2e_r ...
        / electricity_e * electricity_cr;%单位kgCO2，热能转化效率假设80%


    
    CR_heat = waste_weight * waste_fuel_MJ * 1000 *0.8* heat_r ...
        * heat_cr_r;%单位kgCO2，热能转化效率假设80%

    CR_soil = waste_weight * waste_content_wet(6) * (1-waste_content_water(6)) ...
        * soil_cr_r;%单位kgCO2

    F= CE_excavate*0.001 + CE_screen * 0.001 + CE_waste_fuel  ...
        + (CE_T_Fe +  CE_T_incinerator + CE_T_soil)*0.001 ...
        - (CR_Fe + (CR_electricity + CR_heat + CR_soil)*0.001);
    f(i,1) = F;

   if mod(i,1000)==0
        disp(i/n);
    end
end

%单位换算成万吨
for i = 1:n
    f(i,1)=f(i,1)/10000;
end

% %将结果进行升序
% f_sort = sort(f); 
% 
% figure1 = cdfplot(f);
% hold on
% xlabel('碳排放（万吨）');
% ylabel('累积分布');
% title('不同场景累积分布图');
% %legend('正态分布数据');
% grid off;

toc

