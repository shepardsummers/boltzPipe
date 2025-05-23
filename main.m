%% Definition of Parameters
clear, clc;

% Domain Related
N_x = 100; % num of x nodes
N_y = 41; % num of y nodes
d_x = 1; % dist between x nodes
d_y = 1; % dist between y nodes

% LBM Related
% Lattice velocity
ksi = [0 1 0 -1 0 1 -1 -1 1; ...
       0 0 1 0 -1 1 1 -1 -1 ];

w = [4/9 1/9 1/9 1/9 1/9 1/36 1/36 1/36 1/36]; % weights for D2Q9

c_s = 1/sqrt(3); % speed of sound (D2Q9)

Tau = 1.2; % relaxation time
Rho_in = 2;

%% Initialization
Rho_ref=2;
Rho = ones(1, N_y, N_x)*Rho_ref; % Density
U = zeros(2, N_y, N_x); % Velocity

f = zeros(9, N_y, N_x); % PDF for all 9 directions at all locations

for j = 1:N_y
    for i = 1:N_x
        f(:,j,i) = eqm_d2q9(squeeze(Rho(1,j,i)), squeeze(U(:,j,i)), ksi, w);
    end
end

f_new = f; % Update variable
f_eq = f; % Equilibrium

timer = 5000;

%% Solving

for t=1:timer
    % Streaming / Boundary Conditions
    for j = 1:N_y
        for i = 1:N_x
            if j == 1 % top boundary
                if i == 1 % topleft
                    f_new(1,j,i) = f(1,j,i);
                    f_new(3,j,i) = f(3,j+1,i);
                    f_new(4,j,i) = f(4,j,i+1);
                    f_new(7,j,i) = f(7,j+1,i+1);
                    % Abnormal
                    f_new(2,j,i) = f_new(4,j,i);
                    f_new(5,j,i) = f_new(3,j,i);
                    f_new(6,j,i) = Rho_in/2 - f_new(1,j,i)/2 - f_new(3,j,i) - f_new(4,j,i) - f_new(7,j,i);
                    f_new(8,j,i) = f_new(6,j,i);
                    f_new(9,j,i) = f_new(7,j,i);
                elseif i == N_x %topright
                    f_new(1,j,i) = f(1, j, i);
                    f_new(2,j,i) = f(2, j, i-1);
                    f_new(3,j,i) = f(3, j+1, i);
                    f_new(6,j,i) = f(6, j+1, i-1);
                    % Abnormal
                    f_new(4,j,i) = f_new(2,j,i);
                    f_new(5,j,i) = f_new(3,j,i);
                    f_new(7,j,i) = f_new(7,j,i-1);
                    f_new(8,j,i) = f_new(6,j,i);
                    f_new(9,j,i) = f_new(7,j,i);
                else %top
                    f_new(1,j,i) = f(1, j, i);
                    f_new(2,j,i) = f(2, j, i-1);
                    f_new(3,j,i) = f(3, j+1, i);
                    f_new(4,j,i) = f(4, j, i+1);
                    f_new(6,j,i) = f(6, j+1, i-1);
                    f_new(7,j,i) = f(7, j+1, i+1);
                    % Abnormal
                    f_new(5,j,i) = f_new(3,j,i);
                    f_new(8,j,i) = f_new(6,j,i) + (f_new(2,j,i)-f_new(4,j,i))/2;
                    f_new(9,j,i) = f_new(7,j,i) - (f_new(2,j,i)-f_new(4,j,i))/2;
                end
            elseif j == N_y % bot boundary
                if i == 1 %botleft
                    f_new(1,j,i) = f(1, j, i);
                    f_new(4,j,i) = f(4, j, i+1);
                    f_new(5,j,i) = f(5, j-1, i);
                    f_new(8,j,i) = f(8, j-1, i+1);
                    % Abnormal
                    f_new(2,j,i) = f_new(4,j,i);
                    f_new(3,j,i) = f_new(5, j, i);
                    f_new(6,j,i) = f_new(8, j, i);
                    f_new(7,j,i) = Rho_in/2 - f_new(1,j,i)/2  - f_new(4,j,i) - f_new(5,j,i) - f_new(8,j,i);
                    f_new(9,j,i) = f_new(7,j,i);
                elseif i == N_x %botright
                    f_new(1,j,i) = f(1, j, i);
                    f_new(2,j,i) = f(2, j, i-1);
                    f_new(5,j,i) = f(5, j-1, i);
                    f_new(9,j,i) = f(9, j-1, i-1);
                    % Abnormal
                    f_new(3,j,i) = f_new(5,j,i);
                    f_new(4,j,i) = f_new(2,j,i);
                    f_new(6,j,i) = f_new(6,j,i-1);
                    f_new(7,j,i) = f_new(9,j,i);
                    f_new(8,j,i) = f_new(6,j,i);
                else %bot
                    f_new(1,j,i) = f(1, j, i);
                    f_new(2,j,i) = f(2, j, i-1);
                    f_new(4,j,i) = f(4, j, i+1);
                    f_new(5,j,i) = f(5, j-1, i);
                    f_new(8,j,i) = f(8, j-1, i+1);
                    f_new(9,j,i) = f(9, j-1, i-1);
                    % Abnormal
                    f_new(3,j,i) = f_new(5, j, i);
                    f_new(6,j,i) = f_new(8, j, i) + (f_new(4,j,i)-f_new(2,j,i))/2;
                    f_new(7,j,i) = f_new(9,j,i) - (f_new(4,j,i)-f_new(2,j,i))/2;
                end
            elseif i == 1 % left boundary
                f_new(1,j,i) = f(1, j, i);
                f_new(3,j,i) = f(3, j+1, i);
                f_new(4,j,i) = f(4, j, i+1);
                f_new(5,j,i) = f(5, j-1, i);
                f_new(7,j,i) = f(7, j+1, i+1);
                f_new(8,j,i) = f(8, j-1, i+1);
                % Abnormal
                U_x = 1 - (f_new(1,j,i) + f_new(3,j,i) + f_new(5,j,i) + 2*(f_new(4,j,i) + f_new(7,j,i) + f_new(8,j,i)))/Rho_in;
                f_new(2,j,i) = f_new(4,j,i) + Rho_in * U_x * (2/3);
                f_new(6,j,i) = f_new(8,j,i) + (f_new(5,j,i) - f_new(3,j,i))/2 + Rho_in*U_x/6; %double check
                f_new(9,j,i) = f_new(7,j,i) - (f_new(5,j,i) - f_new(3,j,i))/2 + Rho_in*U_x/6; %double check;
            elseif i == N_x % right boundary
                f_new(1,j,i) = f(1, j, i);
                f_new(2,j,i) = f(2, j, i-1);
                f_new(3,j,i) = f(3, j+1, i);
                f_new(5,j,i) = f(5, j-1, i);
                f_new(6,j,i) = f(6, j+1, i-1);
                f_new(9,j,i) = f(9, j-1, i-1);
                % Abnormal
                f_new(4,j,i) = f_new(4, j, i-1);
                f_new(7,j,i) = f_new(7, j, i-1);
                f_new(8,j,i) = f_new(8, j, i-1);
            else % interior
                f_new(1,j,i) = f(1, j, i);
                f_new(2,j,i) = f(2, j, i-1);
                f_new(3,j,i) = f(3, j+1, i);
                f_new(4,j,i) = f(4, j, i+1);
                f_new(5,j,i) = f(5, j-1, i);
                f_new(6,j,i) = f(6, j+1, i-1);
                f_new(7,j,i) = f(7, j+1, i+1);
                f_new(8,j,i) = f(8, j-1, i+1);
                f_new(9,j,i) = f(9, j-1, i-1);
            end
        end
    end
    % Collision
    % Rho, U calculation
    for j = 1:N_y
        for i = 1:N_x
            [Rho(1,j,i), U(:,j,i)] = rhoNu(squeeze(f_new(:,j,i)), ksi);
        end
    end
    % f_eq calculation
    for j = 1:N_y
        for i = 1:N_x
            f_eq(:,j,i) = eqm_d2q9(squeeze(Rho(1,j,i)), squeeze(U(:,j,i)), ksi, w);
        end
    end
    % BGK Collision and Update
    f = f_new - (f_new-f_eq)/Tau;

progress(timer, t);
end

%% Post-Processing / Visualization
y_ben = 0:0.01:1; % benchmark y
u_ben = zeros(length(y_ben));
for i = 1:length(y_ben)
    u_ben(i)=-4*(y_ben(i)^2 - y_ben(i));
end
figure
plot(y_ben, u_ben, "red");

u_sim = zeros(1, N_y);
for j = 1:N_y
    u_sim(j) = U(1,j,N_x);
end
hold on
plot((0:1:N_y-1)/(N_y-1), u_sim/max(u_sim), "blue");

% Sampling u_x velocity from the outlet
for j=1:N_y
    u_sim(j) = U(1,j,N_x);
end
hold on
plot((0:1:N_y-1)/(N_y-1),u_sim/max(u_sim),"blue")

figure
quiver(flipud(squeeze(U(1,:,:))),flipud(squeeze(U(2,:,:))),10)
axis equal tight

figure
contourf(flipud(squeeze(Rho)),30)
axis equal tight