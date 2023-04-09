S = 0.1;
T = 10;

t = 0:0.001:T;
f = S.^(T-t);

figure;
plot(t,f);
xlabel('Time [day]');
ylabel('P(perish)');
title('Probability of the product perishing per timestep');
subtitle('Perishes at '+string(T)+' days old, with sale probability of '+string(S)+' each day');
g = gcf;
exportgraphics(g,'images/Perishable.png','Resolution',300);
