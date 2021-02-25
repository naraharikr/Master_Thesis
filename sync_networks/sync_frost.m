%
%
% Implementation of FROST (Fast Row-stochastic Optimisation with 
% uncordinated STep-sizes) over directed graphs
%
%
%% START: FROST Algorithm

clc; clear; close all;

% Row-stochastic Weight Matrix
% A = [0.5 0.25 0 0 0.25 0;0.25 0.5 0.25 0 0 0;0.5 0 0.5 0 0 0;
%      0.25 0 0.25 0.25 0 0.25;0 0 0 0 0.5 0.5;0 0 0.25 0.25 0 0.5];
% A = [0.3333 0.3333 0.3333 0 0; 0 0.3333 0.3333 0 0.3333; 0 0 0.5 0 0.5; 
%      0.5 0 0 0.5 0; 0 0 0.3333 0.3333 0.3333];
A = [1/3 1/3 1/3 0 0; 0 1/3 1/3 0 1/3; 0 0 1/2 0 1/2; 1/2 0 0 1/2 0; 0 0 1/3 1/3 1/3];
n = length(A);
x = [4 1 5 2 3]';
% x = [3 2 5 6 1 7]';
y = eye(n);
z = x./diag(y);
alpha = [2 4 5 3 1]';
% alpha = [1 3 2 1 4 1]';

% initialization
x_0 = x; x_arxiv = x; 
y_k = y; z_arxiv = z;
imbalanceEliminator = diag(y);
gradientEstimator = x;

% initilization for cost function
for p=1:n
    z(p)=compute_gradient(x_0(p),x_0(p),alpha(p));
end
for q=1:n
    gradientEstimator(q)=compute_gradient(x(q),x_0(q),alpha(q));
end
gradientEstimator_arxiv = gradientEstimator;

% consensus value = optimal_x
average_x = mean(x);
optimal_x = sum(alpha.*x_0)/sum(alpha)

%% FROST Algorithm
itr = 100;
% constant but uncoordianted stepsize
step = 0.005;
for i=1:itr
    y = A*y;
    imbalanceEliminator = [imbalanceEliminator diag(y)];
    x = A*x - step*z_arxiv(:,end);
    x_arxiv = [x_arxiv x];
    for j=1:n
        gradientEstimator(j)=compute_gradient(x(j),x_0(j),alpha(j));
    end
    gradientEstimator_arxiv = [gradientEstimator_arxiv gradientEstimator];
    z = A*z + (gradientEstimator_arxiv(:,end)./imbalanceEliminator(:,end))...
            - (gradientEstimator_arxiv(:,i)./imbalanceEliminator(:,i));
    z_arxiv = [z_arxiv z];
end
%
%
% Average of residuals at each agent
residual_arxiv = zeros(1,itr);
for u=1:itr
    residual_sum=0;
    for v=1:n
        mean_square_error = (x_arxiv(v,u)-optimal_x)^2;
        residual_sum = residual_sum + mean_square_error; 
    end
    residual_arxiv(u)=residual_sum/n;
end
frost_residual_arxiv = residual_arxiv;
save('frost_residual_arxiv');
%% Convergence Results & Residual Plots
set(0, 'DefaultTextInterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')

figure(1); hold on; box on;
plot(0:itr,x_arxiv);
xl=xlabel('Iterations $\rightarrow$','fontsize',14); set(xl, 'Interpreter', 'latex');
yl=ylabel('$x^{i}_k$ at each node','fontsize',14); set(yl, 'Interpreter', 'latex');
title('FROST (Directred Graphs): Synchronous networks'); 
plot([0,itr],[optimal_x,optimal_x], 'r:');
plot([0,itr],[average_x,average_x], 'b-.');

figure(2);hold on; box on;
plot(0:itr,imbalanceEliminator);
xl=xlabel('Iterations $\rightarrow$','fontsize',14); set(xl, 'Interpreter', 'latex');
yl=ylabel('$y^{i}_k$ at each node','fontsize',14); set(yl, 'Interpreter', 'latex');
title('FROST (Directred Graphs): Synchronous networks'); 

figure(3);hold on; box on;
plot(0:itr,z_arxiv);
xl=xlabel('Iterations $\rightarrow$','fontsize',14); set(xl, 'Interpreter', 'latex');
yl=ylabel('$z^{i}_k$ at each node','fontsize',14); set(yl, 'Interpreter', 'latex');
title('FROST (Directred Graphs): Synchronous networks');
plot([0,itr],[0,0], 'r-.')

figure(4); hold off; box on;
plot(1:itr,residual_arxiv);
set(gca, 'YScale', 'log')
xl=xlabel('Iterations $\rightarrow$','fontsize',14); set(xl, 'Interpreter', 'latex');
yl=ylabel('$\frac{1}{n}\sum_{i=1}^{n} (x^{i}_k - x^{*})^{2}$ (Avg. Mean-sqaure error)','fontsize',14); 
set(yl, 'Interpreter', 'latex');
title('FROST Implementation with Quadratic Cost Function');

%% Display consensus result
fprintf('\nFROST Consensus result\n');
display(x);
%% END: FROST Algorithm