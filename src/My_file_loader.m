function [ MI_beg, MI_end, MU_beg, MU_end, DS ] = My_file_loader( FD, US, DS )
    % revision: 21.12.2018

    tic;
    fprintf('Data loading\t->');

    % формирование имени файла:
    FD.folder = strrep(FD.folder, 'fff', num2str(FD.MHz));
    FD.folder = strrep(FD.folder, 'type', FD.k_type);

    FD.fname = strrep(FD.fname, 'lll', num2str(FD.Lx));
    FD.fname = strrep(FD.fname, 'type', FD.k_type);
    FD.fname = strrep(FD.fname, 'xxx', num2str(FD.S1_kx));
    FD.fname = strrep(FD.fname, 'DorM', FD.DM);
    FD.fname = strrep(FD.fname, 'fff', num2str(FD.MHz));
    FD.fname = strrep(FD.fname, 'dddd', num2str(FD.dLx));
    FD.fname = strrep(FD.fname, 'ode', FD.ode_type);

    % инициализация структур:
    MI_beg = NaN;
    MI_end = NaN;
    MU_beg = NaN;
    MU_end = NaN;

    nt = 1e9;   % нано секунда

    if (US.use_i)
        fname = [FD.folder, strrep(FD.fname, 'signals', 'Current')];
        temp = load(fname);
        [ MI_beg ] = funct_signal_bilder( temp(:,2:1:4), temp(:,1), US.I_nom, 'C' );
        [ MI_end ] = funct_signal_bilder( temp(:,5:1:7), temp(:,1), US.I_nom, 'C' );


        if (~isnan(FD.dB))
            MI_beg.sig = awgn(MI_beg.sig, FD.dB, 'measured');
            MI_end.sig = awgn(MI_end.sig, FD.dB, 'measured');
        end
    end

    if (US.use_u)
        fname = [FD.folder, strrep(FD.fname, 'signals', 'Voltage')];
        temp = load(fname);
        ktU = US.U_nom*sqrt(2/3)*1000;  % кт по напряжению
        [ MU_beg ] = funct_signal_bilder( temp(:,2:1:4), temp(:,1), ktU, 'V' );
        [ MU_end ] = funct_signal_bilder( temp(:,5:1:7), temp(:,1), ktU, 'V' );

        if (~isnan(FD.dB))
            MU_beg.sig = awgn(MU_beg.sig, FD.dB, 'measured');
            MU_end.sig = awgn(MU_end.sig, FD.dB, 'measured');
        end
    end

    if (isstruct(MI_beg) && isstruct(MI_end))
        DS.f_adc = int32(nt/(MI_beg.time(2,:) - MI_beg.time(1,:)));
        DS.T_pts = int32(DS.f_adc/DS.f_sys);
    elseif(isstruct(MU_beg) && isstruct(MU_end))
        DS.f_adc = int32(nt/(MU_beg.time(2,:) - MU_beg.time(1,:)));
        DS.T_pts = int32(DS.f_adc/DS.f_sys);
    end

    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end