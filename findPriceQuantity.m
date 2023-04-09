function [equilibriumAmounts,equilibriumPrices] = findPriceQuantity(consumerOffers,producerPrices)
%FINDPRICEQUANTITY Summary of this function goes here
%   Detailed explanation goes here

if max(producerPrices) < min(consumerOffers)
    equilibriumPrices = (max(producerPrices)+min(consumerOffers))/2;
    equilibriumAmounts = length(producerPrices);
    return
end

aggreatePrices = reshape(producerPrices, 1, []);
aggreatePrices = sort(aggreatePrices);

aggreateOffers = reshape(consumerOffers, 1, []);
aggreateOffers = sort(aggreateOffers, 'descend');

equilibriumAmounts = [];
equilibriumPrices = [];

for i = 1:(min(length(aggreatePrices),length(aggreateOffers))-1)
    [equilibriumAmount,equilibriumPrice] = intersect([i,i+1],aggreatePrices(i:i+1),[i,i+1],aggreateOffers(i:i+1));
    equilibriumAmounts(i) = equilibriumAmount;
    equilibriumPrices(i) = equilibriumPrice;
end

equilibriumAmounts(isnan(equilibriumAmounts)) = [];
equilibriumPrices(isnan(equilibriumPrices)) = [];

end