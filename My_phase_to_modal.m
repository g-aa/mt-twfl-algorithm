function [ out_sig ] = My_phase_to_modal( in_sig, DS )
    
    % revision: 08.11.2018
    tic;
    fprintf('\t- phase to modal transformation for Sig\t->');
    
    % преобразователь Кларка (фазо ориентированное):
    out_sig.type = in_sig.type;
    out_sig.phase = in_sig.phase;
    out_sig.size = in_sig.size;
    out_sig.time = in_sig.time;
    tmp = zeros(out_sig.size, out_sig.phase);
    
    if (strcmp(in_sig.type, 'V'))
        M = DS.re_Tu;
    elseif (strcmp(in_sig.type, 'C'))
        M = DS.re_Ti;
    end

    % поворот матрицы в соответствии с особой фазой:
    if ( strcmp(DS.special_ph, 'B') )
        M = [M(:, 3), M(:, 1), M(:, 2)];
    elseif ( strcmp(DS.special_ph, 'C') )
        M = [M(:, 2), M(:, 3), M(:, 1)];
    end

    % вычисление модальной составляющей:
    for t = 1:1:in_sig.size
        tmp(t,:) = M*in_sig.sig(t,:)';
    end
    
    % использовать нулевой модальный канал:
    if(DS.use_mod0)
        out_sig.sig = tmp;
    else
        out_sig.sig(:,:) = tmp(:,2:1:end);
        out_sig.phase = 2;
    end
    
    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end