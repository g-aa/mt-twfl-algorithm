function [ LP ] = My_RLGC_fun( LG, US )
    %������ ���������� (R G L M C K) ����� ���������������:

    m0 = 4*pi*10^-4;    % ��������� ���������� [��/��]
    ma = 1.000022;      % ������������� ��������� ������������� Al
    e0 = 8.85*10^-9;    % ������������� ���������� [�/��]

    % ������������� ������� ������� [�]:
    de = LG.dp/1000;

    LP.R0 = zeros(LG.N_ph);
    LP.G0 = zeros(LG.N_ph);
    LP.L0 = zeros(LG.N_ph);
    LP.C0 = zeros(LG.N_ph);
    A0 = zeros(LG.N_ph);
    LP.size_m = LG.N_ph;

    % ������ ���������� �����:
    for i = 1:1:LG.N_ph
        for j = 1:1:LG.N_ph
            if (i == j)
                LP.R0(i,j) = LG.Rp/LG.np;
                LP.G0(i,j) = (LG.dPk*1000)/((US.U_nom*1000)^2);

                LP.L0(i,j) = m0*(log(LG.Dz/(de/2)) + ma/(4*LG.np))/(2*pi);
                A0(i,j) = 1/(2*pi*e0)*(log(4*LG.Yl(i)/de));
            else
                D = sqrt(((LG.Xl(i) - LG.Xl(j))^2) + ((LG.Yl(i) - LG.Yl(j))^2));
                S = sqrt(((LG.Xl(i) - LG.Xl(j))^2) + ((LG.Yl(i) + LG.Yl(j))^2));

                LP.L0(i,j) = m0*(log(LG.Dz/D))/(2*pi);
                A0(i,j) = 1/(2*pi*e0)*(log(S/D));
            end
        end
    end
    LP.C0 = inv(A0);   % ����������� ������� ��������
end