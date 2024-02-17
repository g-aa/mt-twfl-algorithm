function [ out_struct_sig ] = My_matlab_filter( in_struct_sig, DS, f_type, f_name )
    % revision: 21.12.2018
    tic;
    fprintf(['\t- ', f_type, ' ', f_name, ' filtration for Sig\t->']);

    % ��������� �������:
    FS.type = [];       % ��� IIR, FIR
    FS.sections = [];   % ����� ������
    FS.size = [];       % ����� �������
    FS.gain = [];       % ��
    FS.num = [];        % ��������� (b)
    FS.denom = [];      % ����������� (a)

    % �������� ������� �� *.fcf:
    fid = fopen(strrep([DS.filt_dir, f_name, '.fcf'], 'type', f_type));
    if (fid)
        while ~feof(fid)
            line_ex = fgetl(fid);

            if (contains(line_ex, 'IIR'))
                FS.type = 'IIR';
            elseif(contains(line_ex, 'FIR'))
                FS.type = 'FIR';
            end

            if (strcmp(FS.type, 'IIR'))
                if(contains(line_ex, 'Number of Sections'))
                    FS.sections = sscanf(line_ex, '%% Number of Sections :%d');

                elseif (contains(line_ex, 'SOS Matrix'))
                    for i = 1:1:FS.sections
                        line_ex = fgetl(fid);
                        tmp = sscanf(line_ex, '%f');
                        FS.size = int32(size(tmp,1)/2);
                        FS.num(i,:) = tmp(1:1:FS.size,1)';
                        FS.denom(i,:) = tmp(FS.size+1:1:FS.size*2,1)';
                    end

                elseif (contains(line_ex, 'Scale Values'))
                    for i = 1:1:FS.sections
                        line_ex = fgetl(fid);
                        FS.gain(i,:) = sscanf(line_ex, '%f');
                    end
                end

            elseif(strcmp(FS.type, 'FIR'))
                if(contains(line_ex, 'Filter Length'))
                    FS.size = sscanf(line_ex, '%% Filter Length :%d');

                elseif (contains(line_ex, 'Numerator'))
                    for i = 1:1:FS.size
                        line_ex = fgetl(fid);
                        FS.num(i,:) = sscanf(line_ex, '%f');
                    end
                    FS.gain = 1;
                end
            end
        end
    else
        error('File is not opened');
    end
    fclose(fid);

    % ����������:
    if (strcmp(FS.type, 'IIR'))
        % ����������� ����������:
        out_struct_sig.type = in_struct_sig.type;
        out_struct_sig.phase = in_struct_sig.phase;
        out_struct_sig.size = in_struct_sig.size;
        out_struct_sig.time = in_struct_sig.time;
        out_struct_sig.sig = in_struct_sig.sig;

        for p = 1:1:out_struct_sig.phase
            for i = 1:1:FS.sections
                out_struct_sig.sig(:,p) = FS.gain(i,1)*filter(FS.num(i,:), FS.denom(i,:), out_struct_sig.sig(:,p));
            end
        end

    elseif (strcmp(FS.type, 'FIR'))
        pws = int32(fix(FS.size/2));

        % ����������� ����������:
        out_struct_sig.type = in_struct_sig.type;
        out_struct_sig.phase = in_struct_sig.phase;
        out_struct_sig.size = in_struct_sig.size - FS.size + 1;
        out_struct_sig.time = in_struct_sig.time((pws - 1):1:(in_struct_sig.size - pws), :);
        out_struct_sig.sig = zeros(out_struct_sig.size, out_struct_sig.phase);

        for p = 1:1:out_struct_sig.phase
            cnt = 1;
            for t = 1:1:out_struct_sig.size - pws + 1
                if (t >= pws)
                    a = in_struct_sig.sig((t - pws + 1):1:(t + pws),p);
                    b = FS.num';
                    out_struct_sig.sig(cnt,p) = FS.gain.*b*a;
                    cnt = cnt + 1;
                end
            end
        end
    else
        out_struct_sig.type = in_struct_sig.type;
        out_struct_sig.phase = in_struct_sig.phase;
        out_struct_sig.size = in_struct_sig.size;
        out_struct_sig.time = in_struct_sig.time;
        out_struct_sig.sig = in_struct_sig.sig;
    end

    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end