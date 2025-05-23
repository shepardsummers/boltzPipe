%% Definition of Parameters
clear, clc;

% Domain Related
N_x = 129; % num of x nodes
N_y = N_x; % num of y nodes
d_x = 1; % dist between x nodes
d_y = 1; % dist between y nodes

% LBM Related
% Lattice velocity
ksi = [0 1 0 -1 0 1 -1 -1 1; ...
       0 0 1 0 -1 1 1 -1 -1 ];

w = [4/9 1/9 1/9 1/9 1/9 1/36 1/36 1/36 1/36]; % weights for D2Q9

c_s = 1/sqrt(3); % speed of sound (D2Q9)

Tau = 0.8; % relaxation time
Rho_in = 2;
vis = (Tau-0.5) * c_s^2; % kinematic viscosity
Re = 100; % Reanolds number
L = N_x; % Length of box
U_top = Re*vis/L; % Top velocity
min_error = 0.000001; % error when sim ends

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

timer = 0;
max_timer = 2000;
cont = true;
r = animatedline;


%% Solving

for t = 1:max_timer
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
                    Rho_c = Rho(1,j,i+1);
                    f_new(2,j,i) = f_new(4,j,i);
                    f_new(5,j,i) = f_new(3,j,i);
                    f_new(9,j,i) = f_new(7,j,i);
                    f_new(6,j,i) = (Rho_c - f_new(1,j,i) - f_new(2,j,i) - f_new(3,j,i) - f_new(4,j,i) - f_new(5,j,i) - f_new(7,j,i) - f_new(9,j,i))/2;
                    % f_new(6,j,i) = (rho - others except for 6,8)/2
                    f_new(8,j,i) = f_new(6,j,i);
                elseif i == N_x %topright
                    f_new(1,j,i) = f(1, j, i);
                    f_new(2,j,i) = f(2, j, i-1);
                    f_new(3,j,i) = f(3, j+1, i);
                    f_new(6,j,i) = f(6, j+1, i-1);
                    % Abnormal
                    Rho_c = Rho(1,j,i-1);
                    f_new(4,j,i) = f_new(2,j,i);
                    f_new(5,j,i) = f_new(3,j,i);
                    f_new(8,j,i) = f_new(6,j,i);
                    f_new(7,j,i) = (Rho_c - f_new(1,j,i) - f_new(2,j,i) - f_new(3,j,i) - f_new(6,j,i) - f_new(5,j,i) - f_new(8,j,i) - f_new(4,j,i))/2;
                    f_new(9,j,i) = f_new(7,j,i);
                else %top
                    f_new(1,j,i) = f(1, j, i);
                    f_new(2,j,i) = f(2, j, i-1);
                    f_new(3,j,i) = f(3, j+1, i);
                    f_new(4,j,i) = f(4, j, i+1);
                    f_new(6,j,i) = f(6, j+1, i-1);
                    f_new(7,j,i) = f(7, j+1, i+1);
                    % Abnormal
                    p = f_new(1,j,i) + f_new(2,j,i) + f_new(4,j,i) + 2*(f_new(3,j,i) + f_new(6,j,i) + f_new(7,j,i));
                    f_new(5,j,i) = f_new(3,j,i);
                    f_new(8,j,i) = (1/2)*(-p*U_top + f_new(2,j,i) + 2*f_new(6,j,i) - f_new(4,j,i));
                    f_new(9,j,i) = (1/2)*(p*U_top - f_new(2,j,i) + 2*f_new(7,j,i) + f_new(4,j,i));
                end
            elseif j == N_y % bot boundary
                if i == 1 %botleft
                    f_new(1,j,i) = f(1, j, i);
                    f_new(4,j,i) = f(4, j, i+1);
                    f_new(5,j,i) = f(5, j-1, i);
                    f_new(8,j,i) = f(8, j-1, i+1);
                    % Abnormal
                    Rho_c = Rho(1, j, i+1);
                    f_new(2,j,i) = f_new(4,j,i);
                    f_new(3,j,i) = f_new(5, j, i);
                    f_new(6,j,i) = f_new(8, j, i);
                    f_new(7,j,i) = (Rho_c - f_new(1,j,i) - f_new(4,j,i) - f_new(5,j,i) - f_new(8,j,i) - f_new(2,j,i) - f_new(3,j,i) - f_new(6,j,i))/2;
                    f_new(9,j,i) = f_new(7,j,i);
                elseif i == N_x %botright
                    f_new(1,j,i) = f(1, j, i);
                    f_new(2,j,i) = f(2, j, i-1);
                    f_new(5,j,i) = f(5, j-1, i);
                    f_new(9,j,i) = f(9, j-1, i-1);
                    % Abnormal
                    Rho_c = Rho(1,j,i-1);
                    f_new(3,j,i) = f_new(5,j,i);
                    f_new(4,j,i) = f_new(2,j,i);
                    f_new(7,j,i) = f_new(9,j,i);
                    f_new(6,j,i) = (Rho_c - f_new(1,j,i) - f_new(2,j,i) - f_new(5,j,i) - f_new(9,j,i) - f_new(3,j,i) - f_new(4,j,i) - f_new(7,j,i))/2;
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
                f_new(2,j,i) = f_new(4,j,i);
                f_new(6,j,i) = f_new(8,j,i) + (f_new(5,j,i) - f_new(3,j,i))/2;
                f_new(9,j,i) = f_new(7,j,i) - (f_new(5,j,i) - f_new(3,j,i))/2; 
            elseif i == N_x % right boundary
                f_new(1,j,i) = f(1, j, i);
                f_new(2,j,i) = f(2, j, i-1);
                f_new(3,j,i) = f(3, j+1, i);
                f_new(5,j,i) = f(5, j-1, i);
                f_new(6,j,i) = f(6, j+1, i-1);
                f_new(9,j,i) = f(9, j-1, i-1);
                % Abnormal
                f_new(4,j,i) = f_new(2,j,i);
                f_new(7,j,i) = f_new(9,j,i) + (f_new(5,j,i) - f_new(3,j,i))/2;
                f_new(8,j,i) = f_new(6,j,i) - (f_new(5,j,i) - f_new(3,j,i))/2;
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
    Rho_old = Rho;
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

    [guh, max_error] = res(Rho_old, Rho, min_error);
    
    addpoints(r, t, max_error)
    drawnow

    %progress(timer, t);
end

%% Post-Processing / Visualization
clc;
load Ghia_Re100.mat
figure
quiver(flipud(squeeze(U(1,:,:))),flipud(squeeze(U(2,:,:))),10)
axis equal tight

figure
contourf(flipud(squeeze(Rho)),30)
axis equal tight

Vertical_Sample = U(1, :, 65)/U_top;
Horizontal_Sample = U(2, 65, :)/U_top;

figure
plot(flip(Vertical_Sample), (1:L)/L, flip(u_Ghia), flip(y_Ghia))
%figure
%plot(flip(Vertical_Sample), (1:L)/L)
figure
plot((1:L)/L, squeeze(Horizontal_Sample), flip(x_Ghia), flip(v_Ghia))
%figure
%plot((1:L)/L, squeeze(Horizontal_Sample))
figure
u = flip(squeeze(U(1, :, :)));
v = squeeze(U(2, :, :));
[startX, startY] = meshgrid(1:5:N_x, 1:5:N_y);
verts = stream2(1:N_x,1:N_y,u,v,startX,startY);
streamline(verts)

