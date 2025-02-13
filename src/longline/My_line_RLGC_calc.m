function [ LD ] = My_line_RLGC_calc( LG )
    % Revision: 13.04.2019
    % Расчет параметров (R G L M C K) линии электропередачи
    % LG - line geometry (struct): []
    % LD - line data (struct): [R0; L0; G0; C0; Lx; ph]

    m0 = 4*pi*10^-4;    % магнитная постоянная [Гн/км]
    ma = 1.000022;      % относительная магнитная проницаемость Al
    e0 = 8.85*10^-9;    % электрическая постоянная [Ф/км]
    ea = 1.000570;      % относительная диэлектрическая проницаемость воздуха
    k = 10^3;           % степень

    if (~isstruct(LG))
        disp('error: function line RLGC !!!');
    else
        size_s = max(size(LG));
        LD = repmat( struct( 'R0', zeros(LG.ph), 'L0', zeros(LG.ph), 'G0', zeros(LG.ph), 'C0', zeros(LG.ph), 'Lx', 0, 'ph', 0 ), 1, size_s );

        for s = 1:1:size_s
            A0 = zeros(LG(s).ph);
            LD(s).ph = LG(s).ph;
            LD(s).Lx = LG(s).Lx;

            de = LG(s).dp/k; % эквивалентный диаметр провода [м]

            % Расчет параметров линии:
            for i = 1:1:LG(s).ph
                for j = 1:1:LG(s).ph
                    if (i == j)
                        LD(s).R0(i,j) = LG(s).Rp/LG(s).np;
                        LD(s).G0(i,j) = (LG(s).dPk*k)/((LG(s).UL*k)^2);

                        LD(s).L0(i,j) = m0*(log(LG(s).Dz/(de/2)) + ma/(4*LG(s).np))/(2*pi);
                        A0(i,j) = 1/(2*pi*e0*ea)*(log(4*LG(s).Yl(i)/de));
                    else
                        D = sqrt(((LG(s).Xl(i) - LG(s).Xl(j))^2) + ((LG(s).Yl(i) - LG(s).Yl(j))^2));
                        S = sqrt(((LG(s).Xl(i) - LG(s).Xl(j))^2) + ((LG(s).Yl(i) + LG(s).Yl(j))^2));

                        LD(s).L0(i,j) = m0*(log(LG(s).Dz/D))/(2*pi);
                        A0(i,j) = 1/(2*pi*e0*ea)*(log(S/D));
                    end
                end
            end
            LD(s).C0 = inv(A0);   % определение матрица емкостей
        end
    end
end