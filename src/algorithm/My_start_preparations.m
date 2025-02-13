function [ DS ] = My_start_preparations( DS, US, LG )
    tic;
    fprintf('Start preparations\t->');

    % расчет числа секций:
    DS.sections = max(size(US.section_Lx));
    DS.Lx_sum = sum(US.section_Lx);

    % расчет параметров линии:
    if((DS.sections == 1) && US.matrix_type)
        [ LP ] = My_RLGC_fun( LG, US ); % расчет параметров линии
    else 
        LP = NaN;
    end

    % вывод матриц Ti, Tu, Vf:
    [ DS.re_Tu, DS.re_Ti, DS.Vf ] = My_modal_matrix_calculation( LP, US );

    % расчет скорости для каждого канала и параметров для распределенной линии:
    if (isnan(DS.Vf))
        if (DS.sections > 1)
            % не однородная линия:
            DS.Vf = zeros(max(size(DS.re_Tu)),DS.sections);
            DS.t_ptr.beg = zeros(max(size(DS.re_Tu)),DS.sections + 1);
            DS.t_ptr.end = zeros(max(size(DS.re_Tu)),DS.sections + 1);
            DS.Lx_row = zeros(max(size(DS.re_Tu)),DS.sections + 1);

            for p = 1:1:max(size(DS.re_Tu))
                DS.Vf(p,:) = DS.Vc.*US.section_nc;

                for i = 1:1:(DS.sections + 1)
                    if (i <= DS.sections )
                        DS.t_ptr.beg(p,i+1) = DS.t_ptr.beg(p,i) + (US.section_Lx(1,i)/DS.Vf(p,i))*1e12;
                        DS.t_ptr.end(p,DS.sections-i+1) = DS.t_ptr.end(p,DS.sections-i+2) + (US.section_Lx(1,DS.sections-i+1)/DS.Vf(p,DS.sections-i+1))*1e12;
                        DS.Lx_row(p,i+1) = DS.Lx_row(p,i) + US.section_Lx(1,i);
                    end
                end
                DS.t_ptr.d(p,:) = DS.t_ptr.end(p,:) - DS.t_ptr.beg(p,:);
            end
        else
            % однородная линия:
            DS.Vf = ones(size(DS.re_Tu,1),DS.sections)*DS.Vc*US.section_nc;
        end
    end

    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end