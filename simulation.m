rng(42);


villages = 1:8;
timesteps = 1:500;
maxUnitAmount = 15;
maxGoldExtractedAtTimestep = 5;
totalGoldAvailabilityAtVillage = 500;
priceUpdateParameter = 0.9;
requiredAmoutForWindow = 10;% TODO This should be calculated on demand
lostRelativeRentabilityOfSpace = 0; % For a single item the rentability is always the same
maxInventoryAtVillage = 300;


% Source and destination of trade caravans
s = [1 1 2 2 2 5 6 6 7 8];
t = [2 7 6 5 3 4 5 7 5 7];
% Transport price in proportion to the price of the good
costs     = digraph(s,t,rand(1,length(s)).*0.25); 
% Distances in days
distances = digraph(s,t,randi([1 7],1,length(s)));

% Producer villages
producers = [1 8];
% Consumer villages
consumers = [3 4];

producerCosts = [
    sort(randi([1 50],1,maxUnitAmount))
    sort(randi([1 50],1,maxUnitAmount))
];

consumerOffers = [
    sort(randi([0 30],1,maxUnitAmount),'descend')
    sort(randi([0 30],1,maxUnitAmount),'descend')
];

economicInformation = struct;
for village = villages
    economicInformation(village).village = village;
    economicInformation(village).price = zeros(1,maxUnitAmount);
    economicInformation(village).offer = zeros(1,maxUnitAmount);
    economicInformation(village).gold = 0;
    economicInformation(village).availability = 0;
end
for i = 1:length(producers)
    economicInformation(producers(i)).cost = producerCosts(i,:);
    economicInformation(producers(i)).price = producerCosts(i,:);
end
for i = 1:length(consumers)
    economicInformation(consumers(i)).offer = consumerOffers(i,:);
    economicInformation(village).gold = sum(consumerOffers(i,:));
end
for village = villages
    next = successors(distances,village);
    meanDistance = mean(distances.Edges.Weight(findedge(distances,village,next)));
    economicInformation(village).updateTime = 1+gamrnd(1,meanDistance);
end

oreAvailability = randomOreExtraction(repmat(timesteps,length(villages),1),maxGoldExtractedAtTimestep,totalGoldAvailabilityAtVillage);

pricesAllTime = zeros(length(timesteps),length(villages),maxUnitAmount);
offersAllTime = zeros(length(timesteps),length(villages),maxUnitAmount);

equilibriumPricesAllTime = zeros(length(timesteps),length(villages));
equilibriumAmountAllTime = zeros(length(timesteps),length(villages));

salesAllTime = zeros(length(timesteps));

for time = timesteps
    for village = villages
        economicInformation(village).gold = economicInformation(village).gold + oreAvailability(village,time);
        
        if ismember(village,consumers)
            maxOffer = max(economicInformation(village).offer);
            totalOffer = sum(economicInformation(village).offer);
            differenceOfGold = economicInformation(village).gold*(maxOffer/totalOffer);
            economicInformation(village).offer = max(economicInformation(village).offer / maxOffer * differenceOfGold,0);
        end

        if ismember(village,producers) && max(economicInformation(village).offer) > min(economicInformation(village).cost)
            amount = sum(economicInformation(village).offer > economicInformation(village).price);
            if economicInformation(village).availability + amount < maxInventoryAtVillage
                economicInformation(village).availability = economicInformation(village).availability + amount;
            end
        end

        next = successors(distances,village);
        if economicInformation(village).updateTime < time && ~isempty(next)
            meanDistance = mean(distances.Edges.Weight(findedge(distances,village,next)));
            nextUpdateDeltaTime = gamrnd(1,meanDistance);
                
            economicInformation(village).updateTime = time + nextUpdateDeltaTime;
            sourceVillage = village;
            if length(next) > 1
                targetVillage = randsample(next,1);
            else
                targetVillage = next;
            end


            tripCost = 1 + costs.Edges.Weight(findedge(costs,sourceVillage,targetVillage));
            
            deltaPrice = priceUpdateParameter*(economicInformation(sourceVillage).price - economicInformation(targetVillage).price);
            economicInformation(sourceVillage).price = economicInformation(sourceVillage).price - deltaPrice;
            economicInformation(targetVillage).price = economicInformation(sourceVillage).price + deltaPrice;

            deltaOffer = priceUpdateParameter*(economicInformation(sourceVillage).offer - economicInformation(targetVillage).offer);
            economicInformation(sourceVillage).offer = economicInformation(sourceVillage).offer - deltaOffer;
            economicInformation(targetVillage).offer = economicInformation(targetVillage).offer + deltaOffer;
            
            
            buyer = targetVillage;
            seller = sourceVillage;
            [~,equilibriumPrice] = findPriceQuantity(economicInformation(buyer).offer,economicInformation(seller).price*tripCost);
                
            if ~isempty(equilibriumPrice)
                toBuy = floor(economicInformation(buyer).gold/equilibriumPrice);
                toBuy = min(toBuy,economicInformation(seller).availability);
                toBuy = min(toBuy,maxInventoryAtVillage - economicInformation(buyer).availability);
                
                if toBuy > 0
                    economicInformation(seller).availability = economicInformation(seller).availability - toBuy;
                    economicInformation(buyer).availability = economicInformation(buyer).availability + toBuy;
                    economicInformation(seller).gold = economicInformation(seller).gold + equilibriumPrice*toBuy;
                    economicInformation(buyer).gold = economicInformation(buyer).gold - equilibriumPrice*toBuy;
                    salesAllTime(time) = salesAllTime(time) + 1;
                end
            end
        end

        offer = economicInformation(village).offer;
        price = economicInformation(village).price;
        [equilibriumAmounts,equilibriumPrices] = findPriceQuantity(offer,price);
        if ~isempty(equilibriumPrices)
            equilibriumPricesAllTime(time,village) = equilibriumPrices(1);
        end
        if ~isempty(equilibriumAmounts)
            equilibriumAmountAllTime(time,village) = equilibriumAmounts(1);
        end

        pricesAllTime(time,village,:) = price;
        offersAllTime(time,village,:) = offer;
    end
end


close all;
print = 1;

g = figure;
plot(costs,'Layout','force','EdgeLabel',costs.Edges.Weight);
title('Transport costs proportional to item price');
if print
    g = gcf;
    exportgraphics(g,'images/Costs.png','Resolution',300);
end

figure;
plot(distances,'Layout','force','EdgeLabel',distances.Edges.Weight);
title('Transport round trip time');
if print
    g = gcf;
    exportgraphics(g,'images/Transport.png','Resolution',300);
end

figure;
plot(timesteps,meanOreExtraction(timesteps,maxGoldExtractedAtTimestep,totalGoldAvailabilityAtVillage));
xlabel('Time [day]');
ylabel('Gold [unit]');
title('Mean ore extraction per timestep');
if print
    g = gcf;
    exportgraphics(g,'images/Gold_means.png','Resolution',300);
end

figure;
yyaxis left;
plot(timesteps,mean(equilibriumPricesAllTime,2));
ylabel('Gold [unit]');
hold on;
yyaxis right;
plot(timesteps,mean(equilibriumAmountAllTime,2));
ylabel('Goods [unit]');
xlabel('Time [day]');
legend('Equilibrium price','Equilibrium amount');
title('Average of all equilibrium prices and amounts across time');
if print
    g = gcf;
    exportgraphics(g,'images/Prices.png','Resolution',300);
end

figure;
plot(timesteps,salesAllTime);
xlabel('Time [day]');
ylabel('Amount [unit]');
title('Trades per timestep');
if print
    g = gcf;
    exportgraphics(g,'images/Trades.png','Resolution',300);
end

figure;
yyaxis left;
plot(1:length(oreAvailability),sum(oreAvailability,1));
ylabel('Gold [unit]');
hold on;
yyaxis right;
plot(1:length(oreAvailability),cumsum(sum(oreAvailability,1)));
xlabel('Time [day]');
ylabel('Gold [unit]');
legend('Gold extracted at timestep','Total gold');
title('Aggregate of all gold extraction across time');
if print
    g = gcf;
    exportgraphics(g,'images/Gold_total.png','Resolution',600);
end

figure;
bar([economicInformation(:).gold]);
xlabel('Villages');
ylabel('Gold [unit]');
title('Gold per village at end');
if print
    g = gcf;
    exportgraphics(g,'images/Gold_per_village.png','Resolution',300);
end

figure;
bar([economicInformation(:).availability]);
xlabel('Villages');
ylabel('Goods [unit]');
title('Goods per village at end');
if print
    g = gcf;
    exportgraphics(g,'images/Goods_per_village.png','Resolution',300);
end

figure;
time = 50;
village = 6;
plot(1:maxUnitAmount,squeeze(pricesAllTime(time,village,:)));
hold on;
plot(1:maxUnitAmount,squeeze(offersAllTime(time,village,:)));
plot(1:maxUnitAmount,ones(maxUnitAmount)*sum(oreAvailability(village,1:time)));
xlabel('Goods [unit]');
ylabel('Gold [unit]');
legend('prices','offers','gold at village');
title('Price and offer for goods at time '+string(time)+' at village '+string(village));
if print
    g = gcf;
    exportgraphics(g,'images/Price_and_offer_at_'+string(time)+'_at_'+string(village)+'.png','Resolution',300);
end