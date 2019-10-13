function wtg_stats()
%WTG_STATS Wind turbine power statistics assignment
%   Code submission by: Z0971307

clear
load turbine.mat u_A P_A time_A u_B P_B time_B; %Calling the variables by name so they can be used in nested functions
await_scatterChoice = 1; %Exit flags for the belwo while loops
await_binChoice = 1;

%Two while loops with if statements so the user can choose to:
%Plot scatter graphs of all 5000 samples
%Bin data into 1 m/s wide intervals and plot against means from each bin
while (await_scatterChoice == 1)
scatterChoice = input('\nDo you a plot of the Power Curves? ', 's');
if isequal(scatterChoice,'Yes') ||  isequal(scatterChoice,'yes')
    plotScatter(u_A, P_A, u_B, P_B);
    await_scatterChoice = 0;
elseif isequal(scatterChoice,'No') ||  isequal(scatterChoice,'no')
    await_scatterChoice = 0;
else
    fprintf('\nINCORRECT INPUT\n');
end
end

while (await_binChoice == 1)
binChoice = input('\nDo you a plot of the Power Curves based on binned data? ', 's');
if isequal(binChoice,'Yes') ||  isequal(binChoice,'yes')
    [mean_windA, mean_windB, mean_energyA, mean_energyB, conf_int_upperA, conf_int_lowerA, conf_int_upperB, conf_int_lowerB] = binData(u_A, P_A, u_B, P_B);
    plotBins(mean_windA, mean_windB, mean_energyA, mean_energyB, conf_int_upperA, conf_int_lowerA, conf_int_upperB, conf_int_lowerB);
    await_binChoice = 0;
elseif isequal(binChoice,'No') ||  isequal(binChoice,'no')
    await_binChoice = 0;
else
    fprintf('\nINCORRECT INPUT\n');
end
end
    
    %Plot scatter graphs of all 5000 samples
    function [] = plotScatter(u_A, P_A, u_B, P_B)
        figure(1);
        scatter(u_A,P_A,5,'filled');
         title('Power Curve A');
        xlabel('Wind Speed (m/s)');
        ylabel('Energy generated over 10 minutes (kWh/10 min)');
        grid on
        
        figure(2);
        scatter(u_B,P_B,5,'filled');
         title('Power Curve B');
        xlabel('Wind Speed (m/s)');
        ylabel('Energy generated over 10 minutes (kWh/10 min)');
        grid on
    end
    
    %Bin data into 1 m/s wide intervals
    function [mean_windA, mean_windB, mean_energyA, mean_energyB, conf_int_upperA, conf_int_lowerA, conf_int_upperB, conf_int_lowerB] = binData(u_A, P_A, u_B, P_B)
        for i = 1:25 %One iteration to sort each of the 25 bins
            u_lower =  i-1; 
            u_upper = i;
            u_listA = (u_lower <= u_A) & (u_A < u_upper); %u_listA and u_listB are logic matrices
            u_listB = (u_lower <= u_B) & (u_B < u_upper); %Position x in u_listA is changed to a 'one' if postion x in u_A is within the interval of the bin  
            uA = u_A(u_listA); %Logic matrix compared with vector u_A to filter all relvent samples 
            uB = u_B(u_listB);
            PA = P_A(u_listA);
            PB = P_B(u_listB);
            mean_windA(i,1) = mean(uA); %Mean wind speed of bin
            mean_windB(i,1) = mean(uB);
            mean_energyA(i,1) = mean(PA);%Mean energy of bin
            mean_energyB(i,1) = mean(PB);
            std_energyA(i,1) = std(PA); %Standard deviation of energy of bin
            std_energyB(i,1) = std(PB);
            fprintf('\nSample A standard deviation for %i-%i m/s bin is %f',u_lower,u_upper,std_energyA(i,1));
            fprintf('\nSample B standard deviation for %i-%i m/s bin is %f',u_lower,u_upper,std_energyB(i,1));
        end
        conf_int_upperA = norminv(0.975,mean_energyA,std_energyA); %Upper estimate of mean energy of bin
        conf_int_upperB = norminv(0.975,mean_energyB,std_energyB);
        conf_int_lowerA = norminv(0.025,mean_energyA,std_energyA); %Lower estimate of mean energy of bin
        conf_int_lowerB = norminv(0.025,mean_energyB,std_energyB);   
        fprintf('\n');
    end
     
    %Plots binned data
    function [] = plotBins(mean_windA, mean_windB, mean_energyA, mean_energyB, conf_int_upperA, conf_int_lowerA, conf_int_upperB, conf_int_lowerB)
        subplot(2,1,1)
        scatter(mean_windA,mean_energyA,5,'k','filled');
        hold on;
        scatter(mean_windA,conf_int_upperA,5,'r','filled');
        hold on
        scatter(mean_windA,conf_int_lowerA,5,'b','filled');
        title('Power Curve A binned data');
        xlabel('Mean Wind Speed (m/s)');
        ylabel('Mean Energy generated over 10 minutes (kWh/10 min)');
        legend('Calculated Mean','Upper Estimate','Lower Estimate', 'Location','northwest');
        grid on;
        
        subplot(2,1,2)
        scatter(mean_windB,mean_energyB,5,'k','filled');
        hold on;
        scatter(mean_windB,conf_int_upperB,5,'r','filled');
        hold on
        scatter(mean_windB,conf_int_lowerB,5,'b','filled');
        title('Power Curve B binned data');
        xlabel('Mean Wind Speed (m/s)');
        ylabel('Mean Energy generated over 10 minutes (kWh/10 min)');
        legend('Calculated Mean','Upper Estimate','Lower Estimate', 'Location','northwest');
        grid on;
    end
end
