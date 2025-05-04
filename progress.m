function progress(total,t)
    clc;
    len = 50;
    rat = len/total;
    for i = 1:len
        if i <= (t*rat)
            fprintf("O")
        else
            fprintf("X")
        end
    end
    fprintf("\n")
end

