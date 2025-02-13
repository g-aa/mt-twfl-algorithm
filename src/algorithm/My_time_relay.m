function [ res_time ] = My_time_relay( in_struct_sig, DS )
    % revision 22.12.18
    tic;
    fprintf('\t\t- time relay calculation for Sig\t->');


    % выбор уставки срабатывания:
    if (contains(DS.moment_type, 'skewness'))
        sig_thr = DS.cs_thr; % коэффициент асимметрии
    elseif (contains(DS.moment_type, 'kurtosis'))
        sig_thr = DS.ck_thr; % коэффициент эксцесса
    end

    if (strcmp(DS.rt_type,'max'))
        [ idx ] = max_time_relay( in_struct_sig, sig_thr );
    elseif (strcmp(DS.rt_type,'thr'))
        [ idx ] = thr_time_relay( in_struct_sig, sig_thr );
    end

    res_time = nan(in_struct_sig.phase,1);
    for ch = 1:1:in_struct_sig.phase
        if (~isnan(idx(ch,1)))
            res_time(ch,:) = in_struct_sig.time(idx(ch,:));
        end
    end

    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);

    % расчет времени по максимальному значению входного сигнала:
    function [ max_idx ] = max_time_relay( struct_sig, thr )
        max_idx = NaN(struct_sig.phase, 1);
        for p = 1:1:struct_sig.phase
            max = 0;
            for i = 1:1:struct_sig.size
                if (abs(struct_sig.sig(i,p)) > thr)
                    if ( abs(struct_sig.sig(i,p)) >= max )
                        max = abs(struct_sig.sig(i,p));
                        max_idx(p,1) = i;
                    end
                end
            end
        end
    end

    % расчет времени по превышению порога уставки значением входного сигнала:
    function [ thr_idx ] = thr_time_relay( struct_sig, thr )
        thr_idx = NaN(struct_sig.phase, 1);
        for p = 1:1:struct_sig.phase
            for i = 1:1:struct_sig.size
                if ( thr <= abs(struct_sig.sig(i,p)) )
                    thr_idx(p,1) = i;
                    break;
                end
            end
        end
    end
end