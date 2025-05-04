function [f_eq] = eqm_d2q9(rho, u, ksi, w)

    f_eq = rho * (1 + (ksi'*u)/(1/3) + ((ksi'*u).^2)/(2/9) - ((u')*u)/(2/3)) .* w';
    
end

