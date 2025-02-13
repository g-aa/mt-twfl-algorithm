% запись данных в файл по шаблону:
function [ ] = My_save_to_file( SD, I_res, U_res )

    folder = strrep(SD.folder, 'fff', num2str(SD.F_adc/1000000));
    folder = strrep(folder, 'type', SD.fault_type);

    if (~isfolder(folder))
        mkdir(folder);
    end

    file_str = [ SD.folder, SD.file_name ];
    file_str = strrep(file_str, 'type', SD.fault_type);
    file_str = strrep(file_str, 'lll', num2str(SD.Lx_sum));
    file_str = strrep(file_str, 'xxx', num2str(SD.Lx_kz));
    file_str = strrep(file_str, 'fff', num2str(SD.F_adc/1000000));
    file_str = strrep(file_str, 'dddd', num2str(SD.dLx*1000));
    if (SD.R_sc <= 1)
        file_str = strrep(file_str, 'DorM', 'M');
    else
        file_str = strrep(file_str, 'DorM', 'D');
    end
    file_str = strrep(file_str, 'ode', SD.ode_type);

    file_i = strrep(file_str, 'signals', 'Current');
    file_u = strrep(file_str, 'signals', 'Voltage');

    dlmwrite(file_i, I_res, 'precision',18);
    dlmwrite(file_u, U_res, 'precision',18);

    pF = fopen(input.FullName, 'wt');
    fprintf(pF, '%s\n', [BS.OrgName, BS.Dept_id, BS.VersPG, BS.Note]);
    fprintf(pF, '%u,%uA,0D\n', max(size(input.SigName)), max(size(input.SigName)));

    for i = 1:max(size(input.SigName))
        channel = input.SigArr(:,i);
        max_ch = int32(max(channel))/BS.kg;
        min_ch = int32(min(channel))/BS.kg;
        fprintf(pF,'%u,%s,,,%s,%.2f,0,0,%d,%d\n', i, input.SigName{i,1}, input.SigName{i,2}, BS.kg, min_ch, max_ch);
    end

    fprintf(pF, '%u\n', int32(input.f_sys));
    fprintf(pF, '%s\n', '1');
    fprintf(pF, '%u,%u\n', int32(input.f_adc), int32(max(size(input.SigArr))));
    fprintf(pF, '%s\n', datestr(t_num + input.TimeArr(1,1)/BS.kd, BS.t_str));
    fprintf(pF, '%s\n', datestr(t_num + input.TimeArr(end,1)/BS.kd, BS.t_str));
    fprintf(pF, '%s\n', BS.CodeType);
    fclose(pF);
end