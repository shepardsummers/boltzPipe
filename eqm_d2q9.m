function [f_eq] = eqm_d2q9(rho, u, ksi, w, c_s)

    f_eq = zeros(1, 9);
    
    guh = sum(1 + (ksi'*u)/(c_s^2) + ((ksi'*u).^2)/(2*c_s^4) - (u'*u)/(2*c_s));

    f_eq = w .* rho .* guh;

end

