function [ Charact ] = My_MsKs_calc( SP, LD, SD, TD )
    
    % Revision 14.04.2019
    % генератор блочных матриц ( Ms Ks ):
    
    % SP - simulation parameters (struct)
    % LD - lina data (struct)
    % SD - system data (struct)
    % TD - time data (struct)
    
    
    Ns = max(size(LD)); % число однородных секций линии
    Nx = zeros(Ns, 1);  % число элементов в s - секции
    Charact.Nx = 0; % суммарное число элементов по всем секциям
    
    % 5 - точечный шаблон:
    D = [-025, +048, -036, +016, -003;
         -003, -010, +018, -006, +001;
         +001, -008, +000, +008, -001;
         -001, +006, -018, +010, +003;
         +003, -016, +036, -048, +025];    
    size_d = size(D, 1); % число строк матрицы D      
    
    
    % обработка однородных участков линии:
    for s = 1:1:Ns
        
        idx_d = 1; % индекс строки в матрицы D
        size_ph = LD(s).ph;    % число фаз s - однородного секций линии
        Nx(s) = int32(LD(s).Lx/ SP.dLx);    
        Charact.Nx = Charact.Nx + Nx(s); 
            
        % обработка блочных матриц коэффициентов R, L, G, C:
        ML{s} = zeros(LD(s).ph*Nx(s));
        MR{s} = zeros(LD(s).ph*Nx(s));
        MC{s} = zeros(LD(s).ph*(Nx(s) + 1));
        MG{s} = zeros(LD(s).ph*(Nx(s) + 1));
               
        for x = 1:1:Nx(s)
            for i = 1:1:size_ph
                for j = 1:1:size_ph                
                    ML{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).L0(i,j)*SP.dLx;    
                    MR{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).R0(i,j)*SP.dLx;

                    MC{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).C0(i,j)*SP.dLx;    
                    MG{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).G0(i,j)*SP.dLx;
                end
            end
        end
        
        for x = 1:1:(Nx(s) + 1)
            for i = 1:1:size_ph
                for j = 1:1:size_ph
                    if ((x == 1 && s == 1) || (s == Ns) && (x == Nx(s) + 1))                        
                        MC{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).C0(i,j)*0.5*SP.dLx;    
                        MG{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).G0(i,j)*0.5*SP.dLx;    
                    else
                        MC{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).C0(i,j)*SP.dLx;    
                        MG{s}(i + 3*(x - 1),j + 3*(x - 1)) = LD(s).G0(i,j)*SP.dLx;
                    end         
                end  
            end
        end
        
        
        % обработка блочных матриц связей Ai and Au:
        Au{s} = zeros(size_ph*Nx(s), size_ph*(Nx(s) + 1));
        Ai{s} = zeros(size_ph*(Nx(s) + 1), size_ph*Nx(s));
                
        % обработка диаганали: 
        for x = 1:1:Nx(s)   
            % обработка фазы:
            for ph = 1:1:size_ph
                % обработка элемента матрицы "D":
                for d = 1:1:size_d
                   r = size_ph*(x - 1) + ph; % индекс строки
                   c = size_ph*(x + size_d - d - idx_d) + ph; % индекс колонки
                   Au{s}(r, c) = D(idx_d, size_d - d + 1);
                end
            end
            
            % выбор строки из матрицы "D":
            if ((s == 1 && x < 3) || (s == Ns && x>= Nx(end) - 1))
                idx_d = idx_d + 1;
            end
        end
        
        idx_d = 1; % индекс строки в матрицы D
        % обработка диаганали: 
        for x = 1:1:(Nx(s) + 1)   
            % обработка фазы:
            for ph = 1:1:size_ph
                % обработка элемента матрицы "D":
                for d = 1:1:size_d
                   r = size_ph*(x - 1) + ph; % индекс строки
                   c = size_ph*(x + size_d - d - idx_d) + ph; % индекс колонки
                   Ai{s}(r, c) = D(idx_d, size_d - d + 1);
                end
            end
            
            % выбор строки из матрицы "D":
            if ((s == 1 && x < 3) || (s == Ns && x>= Nx(end)))
                idx_d = idx_d + 1;
            end
        end
        
        % обработка граничных условий:
        if(s == 1)           
            E = eye(LD(s).ph);            
            [ ML{s} ] = DiagBuildBlock( SD(s).L_sys*E, ML{s}, 1);
            [ MR{s} ] = DiagBuildBlock( SD(s).R_sys*E, MR{s}, 1);
            [ Au{s} ] = VertUnion( E, Au{s}, 1);             
        end
        
        if (s == Ns)          
            E = eye(LD(s).ph);                        
            [ ML{s} ] = DiagBuildBlock( ML{s}, SD(s).L_sys*E, 1);
            [ MR{s} ] = DiagBuildBlock( MR{s}, SD(s).R_sys*E, 1);
            [ Au{s} ] = VertUnion( Au{s}, -1*E, 2);
        end
        
        
        if(s == 1)
            ML_sum = ML{s};
            MC_sum = MC{s};
            MR_sum = MR{s};
            MG_sum = MG{s};
            Au_sum = Au{s};
            Ai_sum = Ai{s};
        else
            ML_sum = DiagBuildBlock( ML_sum, ML{s}, 1);
            MC_sum = DiagBuildBlock( MC_sum, MC{s}, 1);
            MR_sum = DiagBuildBlock( MR_sum, MR{s}, 1);
            MG_sum = DiagBuildBlock( MG_sum, MG{s}, 1);
            Au_sum = DiagBuildBlock( Au_sum, Au{s}, 1);
            Ai_sum = DiagBuildBlock( Ai_sum, Ai{s}, 1);
        end
    end
    
    Charact.M = DiagBuildBlock(ML_sum, MC_sum, 1);
    Charact.K = DiagBuildBlock(MR_sum, MG_sum, 1);
    Charact.A = DiagBuildBlock(Au_sum, Ai_sum, 2);
            
    % обьединение блоков матриц:
    function [ M ] = DiagBuildBlock(M1, M2, diag)     
        % diag = 1 - главная диагональ
        % diag = 2 - побочная диагональ
        size_m1 = size(M1);
        size_m2 = size(M2);
        
        if (diag == 1)
            M = blkdiag(M1, M2);
        elseif (diag == 2)
            M = [ zeros(size_m2(1), size_m1(2)), M2;
                     M1, zeros(size_m1(1), size_m2(2)); ]; 
        else
            M = null;
        end
    end

    %
    function [ M ] = HorzUnion(M1, M2, alig )        
        % alig = 1 - вниз
        % alig = 2 - вверх        
        size_m1 = size(M1);
        size_m2 = size(M2);
        
        if ( alig == 1 )
            if(size_m1(1) > size_m2(1))
                temp = [zeros(size_m1(1) - size_m2(1), size_m2(2)); M2 ];
                M = [ M1, temp ];
            elseif(size_m1(1) < size_m2(1))
                temp = [zeros(size_m2(1) - size_m1(1), size_m1(2)); M1 ];
                M = [ temp, M2 ];
            else
                M = [ M1, M2 ];
            end
        elseif ( alig == 2 )
            if(size_m1(1) > size_m2(1))
                temp = [ M2; zeros(size_m1(1) - size_m2(1), size_m2(2)) ];
                M = [ M1, temp ];
            elseif(size_m1(1) < size_m2(1))
                temp = [ M1; zeros(size_m2(1) - size_m1(1), size_m1(2)) ];
                M = [ temp, M2 ];
            else
                M = [ M1, M2 ];
            end
        else
            M = null;
        end        
    end

    % 
    function [ M ] = VertUnion(M1, M2, alig )
        % alig = 1 - левое
        % alig = 2 - правое        
        size_m1 = size(M1);
        size_m2 = size(M2);
        
        if ( alig == 1 )
            if(size_m1(1) > size_m2(1))
                temp = [ M2, zeros(size_m2(1), size_m1(2) - size_m2(2)) ];
                M = [ M1; temp ];
            elseif(size_m1(1) < size_m2(1))
                temp = [ M1, zeros(size_m1(1), size_m2(2) - size_m1(2)) ];
                M = [ temp; M2 ];
            else
                M = [ M1; M2 ];
            end
        elseif ( alig == 2 )
            if(size_m1(1) > size_m2(1))
                temp = [ zeros(size_m2(1), size_m1(2) - size_m2(2)), M2 ];
                M = [ M1; temp ];
            elseif(size_m1(1) < size_m2(1))
                temp = [ zeros(size_m1(1), size_m2(2) - size_m1(2)), M1 ];
                M = [ temp; M2 ];
            else
                M = [ M1; M2 ];
            end 
        else
            M = null;
        end
    end
end