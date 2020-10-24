function [ out_struct_sig ] = My_DWT_pre_filt( in_struct_sig )

    % revision: 08.11.2018
    tic;
    fprintf('\t- prefiltration for Sig\t->');
    
    out_struct_sig.type = in_struct_sig.type;
    out_struct_sig.phase = in_struct_sig.phase;
    out_struct_sig.size = in_struct_sig.size;   
    out_struct_sig.time = in_struct_sig.time;
    out_struct_sig.sig = zeros(in_struct_sig.size, in_struct_sig.phase);
    
    level = 3;
    type = 'bior3.1';         
    for p = 1:1:in_struct_sig.phase
        [ C, L ] = wavedec( in_struct_sig.sig(:,p), level, type );
        out_struct_sig.sig(:,p) = wrcoef('a', C, L, type);
    end
    
    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end