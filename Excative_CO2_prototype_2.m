clc;clear
%相比于prototype1优先使用这个。增加了燃烧的CH4和N2O，不考虑塑料的回收，增加了计时器功能，增加了含碳量的可能性，热能转化效率为80%
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
waste_content_wet = [[0.35,0.1,0.0298,0,0.0075,0.4498]];
%干基塑料、纺织物、竹木、纸张、金属、粗细颗粒土含量
waste_content_dry = [[0.3461,0.0871,0.0256,0,0.016,0.448]];
%湿基组分含水率塑料、纺织物、竹木、纸张、金属、粗细颗粒土
waste_content_water = [0.05,0.3,0.4,0.45,0.01,0.3];
C_content = [[0.7,0.4,0.3,0.4]];%塑料、纺织物、竹木、纸张碳含量




%开挖
excavate = [1.3,1.4,1.5];
excavate_b = 1.3;%开挖一吨垃圾油耗1.3-1.5L/t
excavate_v = 0.2;

%筛分
screen = [5.71,19.44,35];%开挖用电kWh/t
screen_b = 30;
screen_v = 10;
%筛分中轻质物中：塑料、纺织物、竹木、纸张；Fe提取效率
extraction_efficiency = [[0.7,0.9,0.9,0.9,0.9];[0.75,0.75,0.8,0.85,0.7]];

%运输
transport_c = [0.52,0.17,0.085];%kgCO2e/tkm
distance_Fe = [750,500,250];%km
distance_plastic = [750,500,250];%km
distance_other_waste_fuel = [150,100,50];%km
distance_coarse_soil = [150,100,50];%km
distance_fine_soil = [450,300,150];%km

%替代碳排放
Fe_cr = [1.57,0.94,0.38];%生产原材料铁碳排减去二次加工碳排kg CO2e/kg
plastic_cr = [2.62,1.53,0.49];%生产原材料塑料碳排减去二次加工碳排kg CO2e/kg
soil_cr = [5.58,1.74,0.85];%骨料开采碳排放kg CO2e/t
%替代原材料的程度，Fe、塑料
substitution_factor = [[0.6,1];[0.2,0.5]];
electricity_cr = 0.58955;%一度电0.58955kgCO2e/kWh
heat_cr = [0.147,0.073,0.005];%kgCO2e/MJ

%能量转化效率
w2e = [0.15,0.3,0.4];%发电能量转化效率
heat = [0.38,0.65];%热利用能量转化效率


%计算

n=10000;%运行次数
f=zeros(n,1);


for i =1:n%可以用parfor

    excacate_r = datasample(excavate,1);
    screen_r = datasample(screen,1);
    transport_c_r = datasample(transport_c,1);
    distance_Fe_r = datasample(distance_Fe,1);
    distance_plastic_r = datasample(distance_plastic,1);
    distance_other_waste_fuel_r = datasample(distance_other_waste_fuel,1);
    distance_coarse_soil_r = datasample(distance_coarse_soil,1);
    extraction_efficiency_r = datasample([1,2],1); %该循环的提取效率选择
    substitution_factor_r = datasample([1,2],1); %该循环的原材料替代选择
    Fe_cr_r = datasample(Fe_cr,1);
    plastic_cr_r = datasample(plastic_cr,1);
    soil_cr_r = datasample(soil_cr,1);
    heat_cr_r = datasample(heat_cr,1);
    w2e_r = datasample(w2e,1);


    CE_excavate = waste_weight * excacate_r * disel_c;%挖掘碳排放kgCO2e

    CE_screen = waste_weight * screen_r * electricity_cr;%筛分用电碳排放kgCO2e

    waste_fuel_C = 0;%燃烧碳排放，轻质物干基*提取效率*含碳率
    for j = 2:4
        waste_fuel_C = waste_fuel_C + waste_content_dry(j) ...
            *extraction_efficiency(extraction_efficiency_r,j)*C_content(j);
    end
    CE_waste_fuel = waste_weight*(1-water_content) ...
        *waste_fuel_C*0.9*44/12;%90%的燃烧效率，单位吨



    CE_T_Fe = waste_weight*waste_content_wet(5)*(1-waste_content_water(5)) ...
        *distance_Fe_r * transport_c_r;%单位kg CO2

    CE_T_plastic = waste_weight * waste_content_wet(1) ...
        * (1-waste_content_water(1)) * distance_plastic_r *transport_c_r;%单位kg CO2

    tp = 0;%临时参数，织物、竹木、纸张，湿基占比
    for j = 2:4
        tp = tp + waste_content_wet(j);
    end
    CE_T_other_waste_fuel = waste_weight * tp * distance_other_waste_fuel_r ...
        * transport_c_r;%单位kg CO2

    CE_T_soil = waste_weight * waste_content_wet(6) * distance_coarse_soil_r ...
        * transport_c_r;%单位kgCO2


    

    CR_Fe = waste_weight*waste_content_wet(5)*(1-waste_content_water(5)) ...
        * extraction_efficiency(extraction_efficiency_r,5) ...
        * substitution_factor(substitution_factor_r,2) ...
        *Fe_cr_r;%单位 吨CO2
    CR_plastic = waste_weight * waste_content_wet(1) * (1-waste_content_water(1)) ...
        * extraction_efficiency(extraction_efficiency_r,1) ...
        *substitution_factor(substitution_factor_r,1) ...
        *plastic_cr_r;%单位 吨CO2

    waste_fuel_MJ = 0;
    for j = 2:4
        waste_fuel_MJ = waste_fuel_MJ + waste_content_wet(j) ...
            *extraction_efficiency(extraction_efficiency_r,j) ...
            *waste_fuel_e(j);%MJ百分比,单位MJ/kg
    end
    CR_electricity = waste_weight * waste_fuel_MJ * 1000 * w2e_r ...
        / electricity_e * electricity_cr;%单位kgCO2

    if w2e_r == 2
        heat_r = 1;
    elseif w2e_r == 3
        heat_r = 1;
    else 
        heat_r = datasample([1,2],1);
    end
    CR_heat = waste_weight * waste_fuel_MJ * 1000 * heat_r ...
        * heat_cr_r;%单位kgCO2

    CR_soil = waste_weight * waste_content_wet(6) * (1-waste_content_water(6)) ...
        * soil_cr_r;%单位kgCO2

    F= CE_excavate*0.001 + CE_screen * 0.001 + CE_waste_fuel  ...
        + (CE_T_Fe + CE_T_plastic + CE_T_other_waste_fuel + CE_T_soil)*0.001 ...
        - (CR_Fe + CR_plastic + (CR_electricity + CR_heat + CR_soil)*0.001);
    f(i) = F;

    disp(i);
end

%单位换算成万吨
for i = 1:n
    f(i)=f(i)/10000;
end

%将结果进行升序
%f_sort = sort(f); 

figure1 = cdfplot(f);
hold on
xlabel('碳排放（万吨）');
ylabel('累积分布');
title('不同场景累积分布图');
%legend('正态分布数据');
grid off;













