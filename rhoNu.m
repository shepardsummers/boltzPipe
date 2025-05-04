function [rho,u] = rhoNu(f,ksi)
    % This function is self explainitory

    rho = sum(f);

    u = (ksi*f)/rho;
end

