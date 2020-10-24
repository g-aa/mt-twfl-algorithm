function [ out_struct_sig ] = My_DWT_fun( in_struct_sig, DS )

    % revision: 08.11.2018
    tic;
    fprintf('\t\t- DWT calculation for Sig\t->');
    
    out_struct_sig.type = in_struct_sig.type;
    out_struct_sig.phase = in_struct_sig.phase;
    out_struct_sig.size = in_struct_sig.size;   
    out_struct_sig.time = in_struct_sig.time;
    
    Bw = zeros(in_struct_sig.size, in_struct_sig.phase);
   
    unused_levels = 0;
    for p = 1:1:in_struct_sig.phase        
        [ C, L ] = wavedec( in_struct_sig.sig(:,p), DS.DWT_level, DS.DWT_type );        
        for l = 1:1:DS.DWT_level - unused_levels
            Bw(:,p) = Bw(:,p) + wrcoef('d', C, L, DS.DWT_type, DS.DWT_level-l+1);
        end
    end
    
    out_struct_sig.sig = Bw;
    fprintf(['\tcomplete ( ', num2str(toc), ' second)\n']);
end