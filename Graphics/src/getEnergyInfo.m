function [ differenceTableSummaryEnergyData, totalEnergyData ] = getEnergyInfo( data )
%GETENERGYINFO Summary of this function goes here
%   Detailed explanation goes here

%Energy formulas
energyBasal = @(x) (x.basalSumEdgesOfEnergy ./ mean([x.basalW1 x.basalW2], 2)) ./ (2*sqrt(1+(mean([x.basalH1 x.basalH2], 2) ./ mean([x.basalW1 x.basalW2], 2)).^2));
energyApical = @(x) (x.apicalSumEdgesOfEnergy ./ mean([x.apicalW1 x.apicalW2], 2)) ./ (2*sqrt(1+(mean([x.apicalH1 x.apicalH2], 2) ./ mean([x.apicalW1 x.apicalW2], 2)).^2));
aspectRatioBasal = @(x) mean([x.basalH1 x.basalH2], 2) ./ mean([x.basalW1 x.basalW2], 2);
aspectRatioApical = @(x) mean([x.apicalH1 x.apicalH2], 2) ./ mean([x.apicalW1 x.apicalW2], 2);
totalEnergyCalculation = @(x) horzcat(energyBasal(x), energyApical(x), aspectRatioBasal(x), aspectRatioApical(x));


totalEnergyData = totalEnergyCalculation(data);

differenceTableSummary = @(x) vertcat(mean(x(:, 2)), ...
    std(x(:, 2)), ...
    mean(x(:, 1)),...
    std(x(:, 1)), ...
    sum(x(:, 1) - x(:, 2)), ...
    mean(x(:, 1) - x(:, 2)), ...
    std(x(:, 1) - x(:, 2)),  ...
    sum(abs(x(:, 1) - x(:, 2))),  ...
    mean(abs(x(:, 1) - x(:, 2))),  ...
    std(abs(x(:, 1) - x(:, 2))));

differenceTableSummaryReduction = @(x) vertcat(mean(x(:, 2)), ...
    std(x(:, 2)), ...
    mean(x(:, 1)),...
    std(x(:, 1)), ...
    sum(-x(:, 1) + x(:, 2)), ...
    mean(-x(:, 1) + x(:, 2)), ...
    std(-x(:, 1) + x(:, 2)),  ...
    sum(abs(-x(:, 1) + x(:, 2))),  ...
    mean(abs(-x(:, 1) + x(:, 2))),  ...
    std(abs(-x(:, 1) + x(:, 2))));


differenceTableSummaryEnergyData = differenceTableSummary(totalEnergyData);

end
