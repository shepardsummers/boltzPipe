function [rho,u] = rhoNu(f,ksi)
    % This function is self explainitory

    rho = sum (f, 1);

    u = (ksi*f)/rho;
end

