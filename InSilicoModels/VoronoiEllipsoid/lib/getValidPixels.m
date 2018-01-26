function [ validPxs, innerLayerPxs, outterLayerPxs ] = getValidPixels(pxXs, pxYs, pxZs, ellipsoidInfo, cellHeight )
%GETVALIDPIXELS Summary of this function goes here
%   Detailed explanation goes here
    pxXs = double(pxXs);
    pxYs = double(pxYs);
    pxZs = double(pxZs);
    pxsInOutterLayer = (((((pxXs/ellipsoidInfo.resolutionFactor) - ellipsoidInfo.xCenter)).^2) / (ellipsoidInfo.xRadius + cellHeight)^2) + (((((pxYs/ellipsoidInfo.resolutionFactor)- ellipsoidInfo.yCenter)).^2) / (ellipsoidInfo.yRadius + cellHeight)^2) + (((((pxZs/ellipsoidInfo.resolutionFactor)- ellipsoidInfo.zCenter)).^2) / (ellipsoidInfo.zRadius + cellHeight)^2);

    pxsInInnerLayer = (((((pxXs/ellipsoidInfo.resolutionFactor)- ellipsoidInfo.xCenter)).^2) / ellipsoidInfo.xRadius^2) + (((((pxYs/ellipsoidInfo.resolutionFactor)- ellipsoidInfo.yCenter)).^2) / ellipsoidInfo.yRadius^2) + (((((pxZs/ellipsoidInfo.resolutionFactor)- ellipsoidInfo.zCenter)).^2) / ellipsoidInfo.zRadius^2);

    validPxs = pxsInInnerLayer >= 0.985 & pxsInOutterLayer <= 1.015;
    innerLayerPxs = pxsInInnerLayer >= 0.985 & pxsInInnerLayer < 1.015;
    outterLayerPxs = pxsInOutterLayer > 0.985 & pxsInOutterLayer <= 1.015;
end

