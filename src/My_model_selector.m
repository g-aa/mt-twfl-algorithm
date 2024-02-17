function [ MI_beg, MI_end, MU_beg, MU_end, DS ] = My_model_selector( MI_beg, MI_end, MU_beg, MU_end, US, DS )
    % revision: 21.12.2018

    tic;
    fprintf('Input signal setup\t->');

    %выбор рассматриваемого режима:
    % обработка sig_beg:
    if ((US.use_i && US.use_u) || US.use_i)
        [ rms_i ] = My_fft( MI_beg.sig, DS );
        [ index, flag_ph ] = MaxMinN_Relay( rms_i, US.Iu_thr, true );
    elseif (US.use_u)
        [ rms_u ] = My_fft( MU_beg.sig, DS );
        [ index, flag_ph ] = MaxMinN_Relay( rms_u, US.Ul_thr, false );
    end

    [MI_beg, MU_beg, DS ] = scriber( MI_beg, MU_beg, DS, US, index, flag_ph );



    % обработка sig_end:
    if ((US.use_i && US.use_u) || US.use_i)
        [ rms_i ] = My_fft( MI_end.sig, DS );
        [ index, flag_ph ] = MaxMinN_Relay( rms_i, US.Iu_thr, true );
    elseif (US.use_u)
        [ rms_u ] = My_fft( MU_end.sig, DS );
        [ index, flag_ph ] = MaxMinN_Relay( rms_u, US.Ul_thr, false );
    end

    [MI_end, MU_end, DS ] = scriber( MI_end, MU_end, DS, US, index, flag_ph );

    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);



    % расчет средне квадратичного значения:
    function [ rms ] = My_fft( int_sig, DS )

        T_pts = 40;             % число точек для расчета fft
        f_adc = T_pts*DS.f_sys; % частота дискретизации при 40 точках

        step = DS.T_pts./T_pts; % шаг прореживания
        rms.size = size(int_sig, 1)/step;
        rms.phase = size(int_sig, 2);

        for p = 1:1:rms.phase
            count = 1;
            tmp_40  = zeros(rms.size, 1);
            for t = 1:1:rms.size
                tmp_40(t,:) = int_sig(count,p);
                rms.index(t,:) = count;
                count = count + step;
            end
            [ ~, rms.sig(:,p) ] = funct_fft( tmp_40, DS.f_sys, f_adc, 'Harm', 1, 'off' );
        end
    end



    % Максимальное/минимальное многофазное реле:
    function [ index, flag ] = MaxMinN_Relay( rms_sig, thr, type_r )

        if (type_r)
            thr_fun = @(a, b) a > b;
        else
            thr_fun = @(a, b) a < b;
        end

        i_tmp = NaN(rms_sig.phase, 1);
        flag = false(rms_sig.phase, 1);

        for p = 1:1:rms_sig.phase
            for t = 1:1:rms_sig.size
                if ( thr_fun(rms_sig.sig(t,p), thr) && ~flag(p,:))
                    i_tmp(p,:) = rms_sig.index(t,:);
                    flag(p,:) = true;
                    break;
                end
            end
        end
        index = min(i_tmp);
    end


    % определение повреждения, особой фазы и обработка осциллограммы:
    function [out_sig_i, out_sig_u, DS ] = scriber( in_sig_i, in_sig_u, DS, US, index, flag_ph )

        out_sig_i = NaN;
        out_sig_u = NaN;

        % тип повреждения:
        if (isnan(DS.err_type))
            str_ph = 'ABC';
            for p = 1:1:size(flag_ph,1)
                if (flag_ph(p))
                    if (isnan(DS.err_type))
                        DS.err_type = str_ph(p);
                    else
                        DS.err_type = strcat(DS.err_type, str_ph(p));
                    end
                end
            end
            DS.special_ph = DS.err_type(1); % определение особой фазы
        end

        if (US.use_i)
            [ out_sig_i ] = sub_scriber( in_sig_i, DS, index );
        end

        if (US.use_u)
            [ out_sig_u ] = sub_scriber( in_sig_u, DS, index );
        end
    end



    % обработка сигнала: вычленение режима + шум:
    function [ out_struct_sig ] = sub_scriber( in_struct_sig, DS, index )

        % обработка in_struct_sig:
        if (~isnan(index))
            L = round(DS.T_num/2);
            R = fix(DS.T_num/2);
            index_arr = (index - L*DS.T_pts):1:(index + R*DS.T_pts);
        else
            index_arr = in_struct_sig.size;
        end

        out_struct_sig.type = in_struct_sig.type;
        out_struct_sig.phase = in_struct_sig.phase;
        out_struct_sig.size = max(size(index_arr));
        out_struct_sig.time = in_struct_sig.time(index_arr,:);
        out_struct_sig.sig = in_struct_sig.sig(index_arr,:);
    end
end