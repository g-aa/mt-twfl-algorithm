function [ SD ] = My_system_RL_calc( SD )
    % Revision: 13.04.2019
    % Расчет параметров систем:
    % SD - system data (struct): [ER_sys; R_sys; L_sys; F_sys; UL_sys; Isc_sys; W_sys; XR_sys]

    if (~isstruct(SD))
        disp('error: function system RL !!!');
    else
        size_s = max(size(SD));
        for s = 1:1:size_s
            SD(s).E_sys = sqrt(2/3)*SD(s).UL_sys;
            SD(s).W_sys = 2*pi*SD(s).F_sys;
            Xs = SD(s).UL_sys/(sqrt(3)*SD(s).Isc_sys);
            SD(s).R_sys = Xs/SD(s).XR_sys;
            SD(s).L_sys = Xs/SD(s).W_sys;
        end
    end
end