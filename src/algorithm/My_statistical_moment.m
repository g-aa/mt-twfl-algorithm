function [ struct_cf ] = My_statistical_moment( in_struct_sig, DS )
    % revision: 21.12.2018
    tic;
    fprintf(['\t\t- ', DS.moment_type, ' coefficient calculation for Sig\t->']);

    struct_cf.type = in_struct_sig.type;
    struct_cf.phase = in_struct_sig.phase;
    struct_cf.size = in_struct_sig.size;
    struct_cf.time = in_struct_sig.time;
    struct_cf.sig = zeros(struct_cf.size, struct_cf.phase);

    % выбор коэффициента симметрии/ эксцесса:
    if (contains(DS.moment_type, 'skewness'))
        c_funct = @(win) skewness(win);
    elseif (contains(DS.moment_type, 'kurtosis'))
        c_funct = @(win) kurtosis(win);
    end

    for p = 1:1:in_struct_sig.phase
        for t = DS.moment_size:1:struct_cf.size
            win_arr = in_struct_sig.sig((t - DS.moment_size + 1):1:t,p);
            struct_cf.sig(t,p) = c_funct(win_arr);
        end
    end

    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end