function [ path ] = funct_TWFL( sig_beg, sig_end, US, DS, FD, PS )
 
    % revision: 24.12.2018
    
    [ mod_beg ] = prefilt_and_decomp( sig_beg, DS);
    [ time_struct(1) ] = calculation( mod_beg, US, DS );
    
    [ mod_end ] = prefilt_and_decomp( sig_end, DS);
    [ time_struct(2) ] = calculation( mod_end, US, DS );
    
    [ path ] = My_find_path( time_struct, DS );
    [ path ] = write_path( path, DS, FD );
    
    
    %=====================================================================
    % предварительна€ обработка:
    function [ out_struct_sig ] = prefilt_and_decomp( in_struct_sig, DS)
        
        % предварительна€ фильтраци€ сигнала:
        if (strcmp(DS.pfilt_type, 'dwt'))
            [ out_struct_sig ] = My_DWT_pre_filt( in_struct_sig );
        elseif ( strcmp(DS.pfilt_type, 'iir') || strcmp(DS.pfilt_type, 'fir'))
            filt_name = 'low_pass_1_MHz';
            [ out_struct_sig ] = My_matlab_filter( in_struct_sig, DS, DS.pf_type, filt_name );
        else
            out_struct_sig = in_struct_sig;
        end
        
        % преобразование abc -> alpha, betta, zero:
        [ out_struct_sig ] = My_phase_to_modal( out_struct_sig, DS );        
    end


    % определение времени прихода Ёћ волн:
    function [ time_struct ] = calculation( in_struct_sig, US, DS )
                
        if (US.EMC_use)
            fprintf('\t- EMC algoritm:\n');
            [ emc_sig ] = My_emerg_comp( in_struct_sig, DS ); 
            [ emc_ce ] = My_statistical_moment( emc_sig, DS );
            [ time_struct.emc ] = My_time_relay( emc_ce, DS );
        end
        
        if (US.IIR_use)
            fprintf('\t- IIR algoritm:\n');           
            filter_type = 'iir';
            filt_name = 'high_pass_2_kHz';
            [ iir_sig ] = My_matlab_filter( in_struct_sig, DS, filter_type, filt_name );
            [ iir_ce ] = My_statistical_moment( iir_sig, DS );
            [ time_struct.iir ] = My_time_relay( iir_ce, DS );
        end
        
        if (US.DWT_use)
            fprintf('\t- DWT algoritm:\n');
            [ dwt_sig ] = My_DWT_fun( in_struct_sig, DS );
            [ time_struct.dwt ] = My_time_relay( dwt_sig, DS );     
        end
    end


    % вывод результата расчета на экран:
    function [ path_struct ] = write_path( path_struct, DS, FD )
        
        str_h = '\t\t- type_e result: %d km, fault type: %s\n';
        str_r1 = '\t\t\t- mod %d: %.3f km, +-%.3f m, err: %.3f %%\n';
        str_r2 = '\t\t\t- mod %d: NaN km, NaN m, err: NaN \n';
        
        size_idx = size(path_struct, 2);
        fault = 4*DS.Vc/DS.f_adc;
            
        for idx = 1:1:size_idx
            size_m = size(path_struct(idx).calc, 1);
            fprintf(strrep(str_h, 'type_e', path_struct(idx).type), FD.S1_kx, FD.k_type);    
            
            for m = 1:1:size_m
                if (size_m > 2)
                    i = m - 1;
                else
                    i = m;
                end

                if (~isnan(path_struct(idx).calc(m)))
                    path_struct(idx).fault(m) = fault;
                    path_struct(idx).err_p(m) = abs((path_struct(idx).calc(m) - FD.S1_kx)/FD.S1_kx);
                    fprintf(str_r1, i, path_struct(idx).calc(m), fault, path_struct(idx).err_p(m));
                else
                    path_struct(idx).fault(m) = NaN;
                    path_struct(idx).err_p(m) = NaN;
                    fprintf(str_r2, i);
                end
            end        
        end
    end
       
        
        
        
       
%     if (MD.in_print)
%         SL.title_beg = 'Input Begin Signal';
%         SL.title_end = 'Input End Signal';
%         
%         for p = 1:1:sig_beg.phase
%             SL.legend_beg{p} = sprintf('Sig beg ph %c', char(65+p-1));
%             SL.legend_end{p} = sprintf('Sig end ph %c', char(65+p-1));            
%         end                
%         funct_print3ph( sig_beg, sig_end, SL );
%     end
%     
%        
%    
%             
%     if (MD.filt_print)
%         SL.title_beg = 'Input Begin Signal';
%         SL.title_end = 'Input End Signal';
%         SL.legend_beg = [];
%         SL.legend_end = [];
%                 
%         for p = 1:1:sig_beg.phase
%             SL.legend_beg{p} = sprintf('Sig beg ph %c', char(65+p-1));
%             SL.legend_end{p} = sprintf('Sig end ph %c', char(65+p-1));            
%         end                
%         funct_print3ph( sig_beg, sig_end, SL );
%     end        
%     
%     
%     if (MD.mod_print)                
%         SL.title_beg = 'Modal Signal Bigin';
%         SL.title_end = 'Modal Signal End';
%         SL.legend_beg = [];
%         SL.legend_end = [];
%         
%         for p = 1:1:MOD_beg.phase
%             if (MOD_beg.phase > 2)
%                 SL.legend_beg{p} = sprintf('Sig beg mod %u', p-1);
%                 SL.legend_end{p} = sprintf('Sig end mod %u', p-1);
%             else
%                 SL.legend_beg{p} = sprintf('Sig beg mod %u', p);
%                 SL.legend_end{p} = sprintf('Sig end mod %u', p);
%             end
%         end
%         funct_print3ph( MOD_beg, MOD_end, SL );
%     end      
%     
%     
%     % расчет по аварийной составл€ющей:
%     if (US.EMC_use)
%     fprintf('\t- emergency component algoritm:\n');
%          
%         % расчет аварийной состалению:
%         [ EMC_beg ] = My_emerg_comp( MOD_beg, DS );
%         [ EMC_end ] = My_emerg_comp( MOD_end, DS );
%             
% 
%         if (MD.EMC_print)
%             SL.title_beg = 'Emergency Component Modal Signal Bigin';
%             SL.title_end = 'Emergency Component Modal Signal End';
%             SL.legend_beg = [];
%             SL.legend_end = [];
% 
%             for p = 1:1:EMC_beg.phase-1
%                 if (EMC_beg.phase > 2)
%                     SL.legend_beg{p} = sprintf('EMC Sig beg mod %u', p-1);
%                     SL.legend_end{p} = sprintf('EMC Sig end mod %u', p-1);
%                 else
%                     SL.legend_beg{p} = sprintf('EMC Sig beg mod %u', p);
%                     SL.legend_end{p} = sprintf('EMC Sig end mod %u', p);
%                 end
%             end
%             funct_print3ph( EMC_beg, EMC_end, SL );
%         end
% 
% 
%         % расчет коэффициента эксцесса: 
%         [ KE_beg ] = My_kurtosis_wave( EMC_beg, DS );        
%         [ KE_end ] = My_kurtosis_wave( EMC_end, DS );
% 
% 
%         if (MD.eKf_print)
%             SL.title_beg = 'Kurtosis (skewness) Coefficient Signal Bigin';
%             SL.title_end = 'Kurtosis (skewness) Coefficient Signal End';
%             SL.legend_beg = [];
%             SL.legend_end = [];
% 
%             for p = 1:1:KE_beg.phase-1
%                 if (KE_beg.phase > 2)
%                     SL.legend_beg{p} = sprintf('kf beg mod %u', p-1);
%                     SL.legend_end{p} = sprintf('kf end mod %u', p-1);
%                 else
%                     SL.legend_beg{p} = sprintf('kf beg mod %u', p);
%                     SL.legend_end{p} = sprintf('kf end mod %u', p);
%                 end
%             end
% 
%             funct_print3ph( KE_beg, KE_end, SL );
%         end
end