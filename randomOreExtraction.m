function [extractedOre] = randomOreExtraction(time,maxExtraction,completeOreAvailability)
%RANDOMOREEXTRACTION Summary of this function goes here
%   Detailed explanation goes here
meanOre = meanOreExtraction(time,maxExtraction,completeOreAvailability);
extractedOre = gamrnd(1,meanOre);
end