function [ ] = main( )
    % revision 14.04.2019

    % параметры моделирования:
    SimulationParameters.folder = 'oscillograms\fff_MHz\type\';
    SimulationParameters.file_name = 'signals_Lx_lll_km_s1_type_xxx_km_DorM_Fadc_fff_MHz_dLx_dddd_m_ode.txt';
    SimulationParameters.ode_type = 'ode23t'; % тип использового решателя
    SimulationParameters.sim_pts = 100000; % число точек для моделирования на 1 шаг итерации
    SimulationParameters.num_iters = []; % число итераций расчета
    SimulationParameters.sum_pts = [];    % суммарное число точек моделирования
    SimulationParameters.t_unit = 1/1e9;  % время в нс.

    SimulationParameters.dLx = 10; % шаг разбиения по пространству [км]
    SimulationParameters.F_adc = 1.0*1e6; % частота дискретизаци сигнала [Гц]
    SimulationParameters.fault_type = 'ABC';  % тип повреждения
    SimulationParameters.Lx_kz = 12; % место повреждения [км]
    SimulationParameters.dLx_kz = 5;  % приращение к мету повреждения [км]
    SimulationParameters.R_sc = 10.0; % переходное сопротивление в точке кз [Ом]
    SimulationParameters.R_brk = 1e6; % сопротивление разрыва цепи [Ом]

    % Геометрические пораметры опоры ЛЭП (110 kV):
    LineGeometry(1).Xl = [ -02.1; +04.2; +02.1 ]; % X - расстояние по горизонтали от центра опоры до провода [м]
    LineGeometry(1).Yl = [ +19.0; +19.0; +23.0 ]; % Y - высота подвеса провода [м]
    LineGeometry(1).np = 1;     % число проводов в расщпленной фазе
    LineGeometry(1).dp = 15.2;  % диаметр провода АС-120/19 [мм]
    LineGeometry(1).a = 0.00;   % растояние между проводами расщепленной фазы [м]
    LineGeometry(1).Rp = 0.2440;    % омическое сопротивление провода АС-120/19 [Ом/км]
    LineGeometry(1).dPk = 0.08; % среднегодовые потери на короны для ВЛ 110 кВ [кВт/км]
    LineGeometry(1).Dz = 1000;  % глубина залегания обратного провода в земле [м]
    LineGeometry(1).ph = 3;     % число фаз линии
    LineGeometry(1).UL = 110;   % класс напряжения линии [кВ]
    LineGeometry(1).Lx = 100;   % протяженность линии [км]

    % Геометрические пораметры опоры ЛЭП (110 kV):
%     LineGeometry(2).Xl = [ -02.1; +04.2; +02.1 ]; % X - расстояние по горизонтали от центра опоры до провода [м]
%     LineGeometry(2).Yl = [ +19.0; +19.0; +23.0 ]; % Y - высота подвеса провода [м]
%     LineGeometry(2).np = 1;     % число проводов в расщпленной фазе
%     LineGeometry(2).dp = 15.2;  % диаметр провода АС-120/19 [мм]
%     LineGeometry(2).a = 0.00;   % растояние между проводами расщепленной фазы [м]
%     LineGeometry(2).Rp = 0.2440;    % омическое сопротивление провода АС-120/19 [Ом/км]
%     LineGeometry(2).dPk = 0.08; % среднегодовые потери на короны для ВЛ 110 кВ [кВт/км]
%     LineGeometry(2).Dz = 1000;  % глубина залегания обратного провода в земле [м]
%     LineGeometry(2).ph = 3;     % число фаз линии
%     LineGeometry(2).UL = 110;   % класс напряжения линии [кВ]
%     LineGeometry(2).Lx = 100;   % протяженность линии [км]

    % параметры системы S1:
    SystemData(1).UL_sys = 115; % линейное напряжение системы (RMS) [кВ]
    SystemData(1).F_sys = 50;   % частота колеманий системы [Гц]
    SystemData(1).psi_sys = 0;  % фаза системы [град.]
    SystemData(1).Isc_sys = 5.0;    % трехфазный ток короткого зымакания на шинах системы [кА]
    SystemData(1).XR_sys = 7;   % соотношение сопротивлений системы [о.е.]

    % параметры системы S2:
    SystemData(2).UL_sys = 105; % линейное напряжение системы (RMS) [кВ]
    SystemData(2).F_sys = 50;   % частота колеманий системы [Гц]
    SystemData(2).psi_sys = -5;  % фаза системы [град.]
    SystemData(2).Isc_sys = 3.0;    % трехфазный ток короткого зымакания на шинах системы [кА]
    SystemData(2).XR_sys = 5;   % соотношение сопротивлений системы [о.е.]

    % параметры таймеров моделирования:
    TimeData.t_beg = 0.00;  % время начала моделирования [с]
    TimeData.t_end = 0.24;  % время окончания моделирования [с]
    TimeData.ts1_on = 0.001;    % время включения системы s1 [с]
    TimeData.ts1_off = -1;  % время отключение системы s1 [с]
    TimeData.ts2_on = 0.061;    % время включения системы s2 [с]
    TimeData.ts2_off = -1;  % время отключения системы s2 [с]
    TimeData.tsc_on = 0.141;    % время включения на кз [с]
    TimeData.tsc_off = -1;    % время отключения кз [с]

    % предварительный расчет:
    SimulationParameters.sum_pts = int32(TimeData.t_end*SimulationParameters.F_adc);
    SimulationParameters.num_iters = int32(fix(SimulationParameters.sum_pts/SimulationParameters.sim_pts));

    if (int32(mod(SimulationParameters.sum_pts, SimulationParameters.sim_pts)) > 0)
        SimulationParameters.num_iters = SimulationParameters.num_iters + 1;
    end

    [ LineData ] = My_line_RLGC_calc( LineGeometry );
    [ SystemData ] = My_system_RL_calc( SystemData );
    [ Charact ] = My_MsKs_calc( SimulationParameters, LineData, SystemData, TimeData );

    % начальные условия:
    Charact.Nx_sc = int32(SimulationParameters.Lx_kz/ SimulationParameters.dLx);
    Charact.St = zeros(size(Charact.M,1),1);
    Charact.y0 = zeros(size(Charact.M,1),1);
    Charact.t_span = (TimeData.t_beg:(1/SimulationParameters.F_adc):TimeData.t_end)';

    % внешний цикл расчета:
    y0 = Charact.y0;

    for i = 1:1:SimulationParameters.num_iters

        idx_beg = (i - 1)*SimulationParameters.sim_pts + 1;
        idx_end = i*SimulationParameters.sim_pts;

        if (i == SimulationParameters.num_iters)
            t_temp = Charact.t_span(idx_beg:1:end, :)';
        else
            t_temp = Charact.t_span(idx_beg:1:idx_end, :)';
        end

        % выбор метода решения системы уравнений:
        options = odeset('Mass', Charact.M, 'OutputFcn', @odeplot, 'OutputSel', 1);

        if (strcmp(SimulationParameters.ode_type, 'ode15s'))
            [ t, y ] = ode15s(@ode_fun, t_temp, y0, options);
        elseif(strcmp(SimulationParameters.ode_type, 'ode45'))
            [ t, y ] = ode45(@ode_fun, t_temp, y0, options);
        elseif(strcmp(SimulationParameters.ode_type, 'ode23t'))
            [ t, y ] = ode23t(@ode_fun, t_temp, y0, options);
        end

        % запись результата расчета:
        % t [ns], U [В], I [A]
        if (i == 0)
            Beg_res = [t*SimulationParameters.t_unit, y(:,(Charact.Nx+2)*3+1:1:(Charact.Nx+2)*3+3)*1e3, y(:,4:1:6)*1e3];
            End_res = [t*SimulationParameters.t_unit, y(:,end-2:1:end)*1e3, y(:,(Charact.Nx)*3+1:1:(Charact.Nx)*3+3)*1e3];
        else
            temp1 = [t*SimulationParameters.t_unit, y(:,(Charact.Nx+2)*3+1:1:(Charact.Nx+2)*3+3)*1e3, y(:,4:1:6)*1e3];
            temp2 = [t*SimulationParameters.t_unit, y(:,end-2:1:end)*1e3, y(:,(Charact.Nx)*3+1:1:(Charact.Nx)*3+3)*1e3];
            Beg_res = [Beg_res; temp1];
            End_res = [End_res; temp2];
        end

        % начальные условия:
        y0 = y(end, :)';
        y = []; t = [];
    end

    % ODE function:
    function [ yt ] = ode_fun(t, y)

        % параметризация режима:
        % включение на источник S1:
        if (t < TimeData.ts1_on)
            Em = [0; 0];

            % отключение источника S2:
            Charact.K(3*(Charact.Nx + 1) + 1, 3*(Charact.Nx + 1) + 1) = SimulationParameters.R_brk;
            Charact.K(3*(Charact.Nx + 1) + 2, 3*(Charact.Nx + 1) + 2) = SimulationParameters.R_brk;
            Charact.K(3*(Charact.Nx + 1) + 3, 3*(Charact.Nx + 1) + 3) = SimulationParameters.R_brk;

        elseif (t >= TimeData.ts1_on)
            Em = [SystemData(1).E_sys; 0];
        end

        % включение на источник S2:
        if (t >= TimeData.ts2_on)
            Em = [SystemData(1).E_sys; SystemData(2).E_sys];

            Charact.K(3*(Charact.Nx + 1) + 1, 3*(Charact.Nx + 1) + 1) = SystemData.Rsys(2);
            Charact.K(3*(Charact.Nx + 1) + 2, 3*(Charact.Nx + 1) + 2) = SystemData.Rsys(2);
            Charact.K(3*(Charact.Nx + 1) + 3, 3*(Charact.Nx + 1) + 3) = SystemData.Rsys(2);
        end

        % включение на КЗ:
        if (t >= TimeData.tsc_on && TimeData.tsc_on ~= 0)

            % типы коротких замыканий:
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

        % отключение КЗ:
%         if ((t >= TData.tv_kz && TData.to_kz ~= 0))
%             Em = [0; 0];
%             % отключение источника S1:
%             odeST.Ks(1,1) = MData.R_brk;
%             odeST.Ks(2,2) = MData.R_brk;
%             odeST.Ks(3,3) = MData.R_brk;
%             % отключение источника S2:
%             odeST.Ks(3*(odeST.Nx+1) + 1, 3*(odeST.Nx+1) + 1) = MData.R_brk;
%             odeST.Ks(3*(odeST.Nx+1) + 2, 3*(odeST.Nx+1) + 2) = MData.R_brk;
%             odeST.Ks(3*(odeST.Nx+1) + 3, 3*(odeST.Nx+1) + 3) = MData.R_brk;
%         end

        % для системы S1:
        Charact.St(1,1) = Em(1)*sin(SystemData(1).W_sys*t + pi*(SystemData(1).psi_sys)/180);
        Charact.St(2,1) = Em(1)*sin(SystemData(1).W_sys*t + pi*(SystemData(1).psi_sys + 240)/180);
        Charact.St(3,1) = Em(1)*sin(SystemData(1).W_sys*t + pi*(SystemData(1).psi_sys + 120)/180);

        % для системы S2:
        Charact.St(3*(Charact.Nx + 1) + 1, 1) = -Em(2)*sin(SystemData(2).W_sys*t + pi*(SystemData(2).psi_sys)/180);
        Charact.St(3*(Charact.Nx + 1) + 2, 1) = -Em(2)*sin(SystemData(2).W_sys*t + pi*(SystemData(2).psi_sys + 240)/180);
        Charact.St(3*(Charact.Nx + 1) + 3, 1) = -Em(2)*sin(SystemData(2).W_sys*t + pi*(SystemData(2).psi_sys + 120)/180);

        yt = Charact.St - ( Charact.K + Charact.A)*y;
    end
end