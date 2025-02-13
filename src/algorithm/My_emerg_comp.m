function [ out_struct_sig ] = My_emerg_comp( in_struct_sig, DS )
    % revision: 08.11.2018
    tic;
    fprintf('\t\t- emergency component calculation for Sig\t->');

    out_struct_sig.type = in_struct_sig.type;
    out_struct_sig.phase = in_struct_sig.phase;
    out_struct_sig.size = in_struct_sig.size - DS.T_pts + 1;
    out_struct_sig.time = zeros(out_struct_sig.size, 1);
    out_struct_sig.sig = zeros(out_struct_sig.size, out_struct_sig.phase);

    for p = 1:1:in_struct_sig.phase
        count = 1;
        for t = DS.T_pts:1:in_struct_sig.size - 1
            out_struct_sig.sig(count,p) = in_struct_sig.sig(t,p) - in_struct_sig.sig(t - DS.T_pts + 1,p);

            if (p == 1)
                out_struct_sig.time(count,:) = in_struct_sig.time(t,:);
            end
            count = count + 1;
        end
    end

    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end