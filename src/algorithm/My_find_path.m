function [ path_struct ] = My_find_path( time_struct, DS )
    idx = 1;

    %
    if (isfield(time_struct(1), 'emc'))
        size_p = size(time_struct(1).emc,1);
        for p = 1:1:size_p
            if( ~isnan(time_struct(1).emc(p,1)) && ~isnan(time_struct(2).emc(p,1)) )
                Dt.emc(p,1) = time_struct(2).emc(p,1) - time_struct(1).emc(p,1);
            else
                Dt.emc(p,1) = NaN;
            end
        end
        [ path_struct(idx).calc ] = sub_path_funct(DS, Dt.emc);
        path_struct(idx).type = 'emc';
        idx = idx + 1;
    end

    %
    if (isfield(time_struct(1), 'dwt'))
        size_p = size(time_struct(1).dwt,1);
        for p = 1:1:size_p
            if( ~isnan(time_struct(1).dwt(p,1)) && ~isnan(time_struct(2).dwt(p,1)) )
                Dt.dwt(p,1) = time_struct(2).dwt(p,1) - time_struct(1).dwt(p,1);
            else
                Dt.dwt(p,1) = NaN;
            end
        end
        [ path_struct(idx).calc ] = sub_path_funct(DS, Dt.dwt);
        path_struct(idx).type = 'dwt';
        idx = idx + 1;
    end

    %
    if (isfield(time_struct(1), 'iir'))
        size_p = size(time_struct(1).iir,1);
        for p = 1:1:size_p
            if( ~isnan(time_struct(1).iir(p,1)) && ~isnan(time_struct(2).iir(p,1)) )
                Dt.iir(p,1) = time_struct(2).iir(p,1) - time_struct(1).iir(p,1);
            else
                Dt.iir(p,1) = NaN;
            end
        end
        [ path_struct(idx).calc ] = sub_path_funct(DS, Dt.iir);
        path_struct(idx).type = 'iir';
    end


    %
    function [ path ] = sub_path_funct(DS, Dt)
        size_dt = size(Dt,1);
        path = NaN(size_dt,1);

        if(DS.sections > 1)
            % не однородная линия:
            for i = 1:1:size_dt
                for s = DS.sections:-1:1
                    if(~isnan(Dt(i,1)))
                        if (DS.t_ptr.d(1,s) >= Dt(i,1) && Dt(i,1) >= DS.t_ptr.d(1,s + 1))
                            path(i,1) = DS.Lx_row(1,s) + 0.5*DS.Vf(i,1)*(DS.t_ptr.d(1,s) - Dt(i,1))*1e-12;
                            break;
                        end
                    end
                end
            end
        else
            % однородная линия:
            for i = 1:1:size_dt
                if (~isnan(Dt(i,1)))
                    tmp(1,1) = (DS.Lx_sum(1,1) - (DS.Vf(i,1)).*(Dt(i,1).*1e-12))./2;
                    if ( 0 <= tmp && tmp <= DS.Lx_sum)
                        path(i,1) = tmp;
                    end
                end
            end 
        end
    end
end