function [ ] = main( )
    % revision 14.04.2019

    % ��������� �������������:
    SimulationParameters.folder = 'oscillograms\fff_MHz\type\';
    SimulationParameters.file_name = 'signals_Lx_lll_km_s1_type_xxx_km_DorM_Fadc_fff_MHz_dLx_dddd_m_ode.txt';
    SimulationParameters.ode_type = 'ode23t'; % ��� ������������ ��������
    SimulationParameters.sim_pts = 100000; % ����� ����� ��� ������������� �� 1 ��� ��������
    SimulationParameters.num_iters = []; % ����� �������� �������
    SimulationParameters.sum_pts = [];    % ��������� ����� ����� �������������
    SimulationParameters.t_unit = 1/1e9;  % ����� � ��.

    SimulationParameters.dLx = 10; % ��� ��������� �� ������������ [��]
    SimulationParameters.F_adc = 1.0*1e6; % ������� ������������ ������� [��]
    SimulationParameters.fault_type = 'ABC';  % ��� �����������
    SimulationParameters.Lx_kz = 12; % ����� ����������� [��]
    SimulationParameters.dLx_kz = 5;  % ���������� � ���� ����������� [��]
    SimulationParameters.R_sc = 10.0; % ���������� ������������� � ����� �� [��]
    SimulationParameters.R_brk = 1e6; % ������������� ������� ���� [��]

    % �������������� ��������� ����� ��� (110 kV):
    LineGeometry(1).Xl = [ -02.1; +04.2; +02.1 ]; % X - ���������� �� ����������� �� ������ ����� �� ������� [�]
    LineGeometry(1).Yl = [ +19.0; +19.0; +23.0 ]; % Y - ������ ������� ������� [�]
    LineGeometry(1).np = 1;     % ����� �������� � ����������� ����
    LineGeometry(1).dp = 15.2;  % ������� ������� ��-120/19 [��]
    LineGeometry(1).a = 0.00;   % ��������� ����� ��������� ������������ ���� [�]
    LineGeometry(1).Rp = 0.2440;    % ��������� ������������� ������� ��-120/19 [��/��]
    LineGeometry(1).dPk = 0.08; % ������������� ������ �� ������ ��� �� 110 �� [���/��]
    LineGeometry(1).Dz = 1000;  % ������� ��������� ��������� ������� � ����� [�]
    LineGeometry(1).ph = 3;     % ����� ��� �����
    LineGeometry(1).UL = 110;   % ����� ���������� ����� [��]
    LineGeometry(1).Lx = 100;   % ������������� ����� [��]

    % �������������� ��������� ����� ��� (110 kV):
%     LineGeometry(2).Xl = [ -02.1; +04.2; +02.1 ]; % X - ���������� �� ����������� �� ������ ����� �� ������� [�]
%     LineGeometry(2).Yl = [ +19.0; +19.0; +23.0 ]; % Y - ������ ������� ������� [�]
%     LineGeometry(2).np = 1;     % ����� �������� � ����������� ����
%     LineGeometry(2).dp = 15.2;  % ������� ������� ��-120/19 [��]
%     LineGeometry(2).a = 0.00;   % ��������� ����� ��������� ������������ ���� [�]
%     LineGeometry(2).Rp = 0.2440;    % ��������� ������������� ������� ��-120/19 [��/��]
%     LineGeometry(2).dPk = 0.08; % ������������� ������ �� ������ ��� �� 110 �� [���/��]
%     LineGeometry(2).Dz = 1000;  % ������� ��������� ��������� ������� � ����� [�]
%     LineGeometry(2).ph = 3;     % ����� ��� �����
%     LineGeometry(2).UL = 110;   % ����� ���������� ����� [��]
%     LineGeometry(2).Lx = 100;   % ������������� ����� [��]

    % ��������� ������� S1:
    SystemData(1).UL_sys = 115; % �������� ���������� ������� (RMS) [��]
    SystemData(1).F_sys = 50;   % ������� ��������� ������� [��]
    SystemData(1).psi_sys = 0;  % ���� ������� [����.]
    SystemData(1).Isc_sys = 5.0;    % ���������� ��� ��������� ��������� �� ����� ������� [��]
    SystemData(1).XR_sys = 7;   % ����������� ������������� ������� [�.�.]

    % ��������� ������� S2:
    SystemData(2).UL_sys = 105; % �������� ���������� ������� (RMS) [��]
    SystemData(2).F_sys = 50;   % ������� ��������� ������� [��]
    SystemData(2).psi_sys = -5;  % ���� ������� [����.]
    SystemData(2).Isc_sys = 3.0;    % ���������� ��� ��������� ��������� �� ����� ������� [��]
    SystemData(2).XR_sys = 5;   % ����������� ������������� ������� [�.�.]

    % ��������� �������� �������������:
    TimeData.t_beg = 0.00;  % ����� ������ ������������� [�]
    TimeData.t_end = 0.24;  % ����� ��������� ������������� [�]
    TimeData.ts1_on = 0.001;    % ����� ��������� ������� s1 [�]
    TimeData.ts1_off = -1;  % ����� ���������� ������� s1 [�]
    TimeData.ts2_on = 0.061;    % ����� ��������� ������� s2 [�]
    TimeData.ts2_off = -1;  % ����� ���������� ������� s2 [�]
    TimeData.tsc_on = 0.141;    % ����� ��������� �� �� [�]
    TimeData.tsc_off = -1;    % ����� ���������� �� [�]

    % ��������������� ������:
    SimulationParameters.sum_pts = int32(TimeData.t_end*SimulationParameters.F_adc);
    SimulationParameters.num_iters = int32(fix(SimulationParameters.sum_pts/SimulationParameters.sim_pts));

    if (int32(mod(SimulationParameters.sum_pts, SimulationParameters.sim_pts)) > 0)
        SimulationParameters.num_iters = SimulationParameters.num_iters + 1;
    end

    [ LineData ] = My_line_RLGC_calc( LineGeometry );
    [ SystemData ] = My_system_RL_calc( SystemData );
    [ Charact ] = My_MsKs_calc( SimulationParameters, LineData, SystemData, TimeData );

    % ��������� �������:
    Charact.Nx_sc = int32(SimulationParameters.Lx_kz/ SimulationParameters.dLx);
    Charact.St = zeros(size(Charact.M,1),1);
    Charact.y0 = zeros(size(Charact.M,1),1);
    Charact.t_span = (TimeData.t_beg:(1/SimulationParameters.F_adc):TimeData.t_end)';

    % ������� ���� �������:
    y0 = Charact.y0;

    for i = 1:1:SimulationParameters.num_iters

        idx_beg = (i - 1)*SimulationParameters.sim_pts + 1;
        idx_end = i*SimulationParameters.sim_pts;

        if (i == SimulationParameters.num_iters)
            t_temp = Charact.t_span(idx_beg:1:end, :)';
        else
            t_temp = Charact.t_span(idx_beg:1:idx_end, :)';
        end

        % ����� ������ ������� ������� ���������:
        options = odeset('Mass', Charact.M, 'OutputFcn', @odeplot, 'OutputSel', 1);

        if (strcmp(SimulationParameters.ode_type, 'ode15s'))
            [ t, y ] = ode15s(@ode_fun, t_temp, y0, options);
        elseif(strcmp(SimulationParameters.ode_type, 'ode45'))
            [ t, y ] = ode45(@ode_fun, t_temp, y0, options);
        elseif(strcmp(SimulationParameters.ode_type, 'ode23t'))
            [ t, y ] = ode23t(@ode_fun, t_temp, y0, options);
        end

        % ������ ���������� �������:
        % t [ns], U [�], I [A]
        if (i == 0)
            Beg_res = [t*SimulationParameters.t_unit, y(:,(Charact.Nx+2)*3+1:1:(Charact.Nx+2)*3+3)*1e3, y(:,4:1:6)*1e3];
            End_res = [t*SimulationParameters.t_unit, y(:,end-2:1:end)*1e3, y(:,(Charact.Nx)*3+1:1:(Charact.Nx)*3+3)*1e3];
        else
            temp1 = [t*SimulationParameters.t_unit, y(:,(Charact.Nx+2)*3+1:1:(Charact.Nx+2)*3+3)*1e3, y(:,4:1:6)*1e3];
            temp2 = [t*SimulationParameters.t_unit, y(:,end-2:1:end)*1e3, y(:,(Charact.Nx)*3+1:1:(Charact.Nx)*3+3)*1e3];
            Beg_res = [Beg_res; temp1];
            End_res = [End_res; temp2];
        end

        % ��������� �������:
        y0 = y(end, :)';
        y = []; t = [];
    end

    % ODE function:
    function [ yt ] = ode_fun(t, y)

        % �������������� ������:
        % ��������� �� �������� S1:
        if (t < TimeData.ts1_on)
            Em = [0; 0];

            % ���������� ��������� S2:
            Charact.K(3*(Charact.Nx + 1) + 1, 3*(Charact.Nx + 1) + 1) = SimulationParameters.R_brk;
            Charact.K(3*(Charact.Nx + 1) + 2, 3*(Charact.Nx + 1) + 2) = SimulationParameters.R_brk;
            Charact.K(3*(Charact.Nx + 1) + 3, 3*(Charact.Nx + 1) + 3) = SimulationParameters.R_brk;

        elseif (t >= TimeData.ts1_on)
            Em = [SystemData(1).E_sys; 0];
        end

        % ��������� �� �������� S2:
        if (t >= TimeData.ts2_on)
            Em = [SystemData(1).E_sys; SystemData(2).E_sys];

            Charact.K(3*(Charact.Nx + 1) + 1, 3*(Charact.Nx + 1) + 1) = SystemData.Rsys(2);
            Charact.K(3*(Charact.Nx + 1) + 2, 3*(Charact.Nx + 1) + 2) = SystemData.Rsys(2);
            Charact.K(3*(Charact.Nx + 1) + 3, 3*(Charact.Nx + 1) + 3) = SystemData.Rsys(2);
        end

        % ��������� �� ��:
        if (t >= TimeData.tsc_on && TimeData.tsc_on ~= 0)

            % ���� �������� ���������:
            if (strcmp(MData.typeK, 'A'))
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 1, 3*(Charact.Nx_sc + Charact.Nx + 2) + 1) = (1/SimulationParameters.R_sc);
            elseif(strcmp(MData.typeK, 'B'))
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 2, 3*(Charact.Nx_sc + Charact.Nx + 2) + 2) = (1/SimulationParameters.R_sc);
            elseif(strcmp(MData.typeK, 'C'))
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 3, 3*(Charact.Nx_sc + Charact.Nx + 2) + 3) = (1/SimulationParameters.R_sc);
            elseif(strcmp(MData.typeK, 'AB'))
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 1, 3*(Charact.Nx_sc + Charact.Nx + 2) + 1) = (1/SimulationParameters.R_sc);
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 2, 3*(Charact.Nx_sc + Charact.Nx + 2) + 2) = (1/SimulationParameters.R_sc);
            elseif(strcmp(MData.typeK, 'BC'))
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 2, 3*(Charact.Nx_sc + Charact.Nx + 2) + 2) = (1/SimulationParameters.R_sc);
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 3, 3*(Charact.Nx_sc + Charact.Nx + 2) + 3) = (1/SimulationParameters.R_sc);
            elseif(strcmp(MData.typeK, 'CA'))
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 1, 3*(Charact.Nx_sc + Charact.Nx + 2) + 1) = (1/SimulationParameters.R_sc);
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 3, 3*(Charact.Nx_sc + Charact.Nx + 2) + 3) = (1/SimulationParameters.R_sc);
            elseif(strcmp(MData.typeK, 'ABC'))
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 1, 3*(Charact.Nx_sc + Charact.Nx + 2) + 1) = (1/SimulationParameters.R_sc);
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 2, 3*(Charact.Nx_sc + Charact.Nx + 2) + 2) = (1/SimulationParameters.R_sc);
                Charact.K(3*(Charact.Nx_sc + Charact.Nx + 2) + 3, 3*(Charact.Nx_sc + Charact.Nx + 2) + 3) = (1/SimulationParameters.R_sc);
            end
        end

        % ���������� ��:
%         if ((t >= TData.tv_kz && TData.to_kz ~= 0))
%             Em = [0; 0];
%             % ���������� ��������� S1:
%             odeST.Ks(1,1) = MData.R_brk;
%             odeST.Ks(2,2) = MData.R_brk;
%             odeST.Ks(3,3) = MData.R_brk;
%             % ���������� ��������� S2:
%             odeST.Ks(3*(odeST.Nx+1) + 1, 3*(odeST.Nx+1) + 1) = MData.R_brk;
%             odeST.Ks(3*(odeST.Nx+1) + 2, 3*(odeST.Nx+1) + 2) = MData.R_brk;
%             odeST.Ks(3*(odeST.Nx+1) + 3, 3*(odeST.Nx+1) + 3) = MData.R_brk;
%         end

        % ��� ������� S1:
        Charact.St(1,1) = Em(1)*sin(SystemData(1).W_sys*t + pi*(SystemData(1).psi_sys)/180);
        Charact.St(2,1) = Em(1)*sin(SystemData(1).W_sys*t + pi*(SystemData(1).psi_sys + 240)/180);
        Charact.St(3,1) = Em(1)*sin(SystemData(1).W_sys*t + pi*(SystemData(1).psi_sys + 120)/180);

        % ��� ������� S2:
        Charact.St(3*(Charact.Nx + 1) + 1, 1) = -Em(2)*sin(SystemData(2).W_sys*t + pi*(SystemData(2).psi_sys)/180);
        Charact.St(3*(Charact.Nx + 1) + 2, 1) = -Em(2)*sin(SystemData(2).W_sys*t + pi*(SystemData(2).psi_sys + 240)/180);
        Charact.St(3*(Charact.Nx + 1) + 3, 1) = -Em(2)*sin(SystemData(2).W_sys*t + pi*(SystemData(2).psi_sys + 120)/180);

        yt = Charact.St - ( Charact.K + Charact.A)*y;
    end
end