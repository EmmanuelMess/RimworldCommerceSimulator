function [meanOre] = meanOreExtraction(time,maxExtraction,completeOreAvailability)
%MEANOREEXTRACTION Summary of this function goes here
%   Detailed explanation goes here

% TODO solve analitically for a and b
syms a b;
M = maxExtraction;
T = completeOreAvailability;

S = vpasolve(a * exp(b * log((b-1)/b)) * (1-exp(-log((b-1)/b))) == M, a/(b*b-b) == T);
clear a b;

a = double(S.a);
b = double(S.b);

meanOre = a.*exp(b.*time).*(1-exp(-time));

end