function [ re_Tu, re_Ti, Vf ] = My_modal_matrix_calculation( LP, US )
    % ���������� re_Tu, re_Ti, Vf ��� ���������� ��������������, ������ ���������� ���:

    if (isstruct(LP))
        w_base = 2*pi*1000; % ������� ������� ���������� ( 1��� )

        Z = complex(LP.R0, w_base.*LP.L0);
        Y = complex(LP.G0, w_base.*LP.C0);

        yu2_ph = Z*Y;
        yi2_ph = Y*Z;

        [ RBu, yu2_mod ] = eig(yu2_ph);
        [ RBi, ~ ] = eig(yi2_ph);

        re_Tu = real(inv(RBu));  % ������� ���������� �������������� ��� U [ �.�. ]
        re_Ti = real(inv(RBi));  % ������� ���������� �������������� ��� I [ �.�. ]

        % �������� ��������������� ���� [ �/� ]
        if (US.speed_type)
            Vf = (w_base*1000)./imag(diag(sqrt(yu2_mod)));
        else
            Vf = NaN;
        end
    else
        s3 = sqrt(3);
        M = (1/3)*[ +1.0, +1.0, +1.0;
                    +2.0, -1.0, -1.0;
                    +0.0, +s3,  -s3 ];
        re_Tu = M;
        re_Ti = M;
        Vf = NaN;
    end
end