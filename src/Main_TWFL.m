function [ ] = Main_TWFL( )

    % revision: 24.12.2018

    % Sig = struct('type', [], 'phase', [], 'size', [], 'time', [], 'sig', []);


    % настройки файла осциллограммы: =====================================
    FileData.folder = 'oscillograms\fff_MHz\type\';
    FileData.fname = 'signals_Lx_lll_km_s1_type_xxx_km_DorM_Fadc_fff_MHz_dLx_dddd_m_ode.txt';
    FileData.Lx = 100;          % протяженность линии [км]
    FileData.k_type = 'ABC';    % тип повреждения
    FileData.S1_kx = 31;        % растояние до места повреждения [км]
    FileData.DM = 'D';          % вид повреждения (D - дуга, M - металлическое КЗ)
    FileData.MHz = 4.0;         % частота дискретизации [МHz]
    FileData.dLx = 500;         % шаг дискретизация по x [м]
    FileData.ode_type = 'ode23t';   % тип решателя уравнений
    FileData.dB = NaN;           % уровень шума в исходном сигнале [дБ]


    % параметры для настройки: ===========================================
    UserSet.U_nom = 110;    % номинальное напряжение линии [В]
    UserSet.I_nom = 150;    % номинальный ток линии [А]
    UserSet.section_Lx = FileData.Lx;   % протяженость однородной секции [км]
    UserSet.section_nc = 1.000; % коэффициент преломления скорости света в линии для секции
    UserSet.Iu_thr = 2.5;   % уставка максимального токового реле [о.е.]
    UserSet.Ul_thr = 0.85;   % уставка минимального реле напряжения [о.е.]
    UserSet.use_i = true;   % использовать ток для расчета ВОМП
    UserSet.use_u = true;   % использовать напряжение для расчета ВОМП
    UserSet.EMC_use = false;    % расчет на основе аварийной составляющей
    UserSet.DWT_use = false;    % расчет на основе DWT преобразования
    UserSet.IIR_use = true;    % расчет на основе ВЧ IIR фильтров 
    UserSet.speed_type = false;  % тип скорости ( false - скорость света в ваккуме; true - скорость расространения в среде/линии )
    UserSet.matrix_type = false; % тип матрицы перехода ( false - Кларк; true - учет геометрии ЛЭП )


    % геометрические пораметры опоры ЛЭП (для уточненного расчета):=======
    LineGeometry.Xl = [ -02.1; +04.2; +02.1 ];   % X - расстояние по горизонтали от центра опоры до провода [ м ]
    LineGeometry.Yl = [ +19.0; +19.0; +23.0 ];   % Y - высота подвеса провода [ м ]
    LineGeometry.dp = 15.2;     % диаметр провода АС-120/19 [ мм ]
    LineGeometry.Rp = 0.2440;   % омическое сопротивление провода АС-120/19 [ Ом/км ]
    LineGeometry.np = 1;        % число проводов в фазе
    LineGeometry.dPk = 0.08;    % среднегодовые потери на короны для ВЛ 110 кВ [ кВт/км ]
    LineGeometry.Dz = 1000;     % глубина залегания эквивалентного обратного провода в земле [ м ]
    LineGeometry.N_ph = 3;      % число фаз


    % системные параметры: ===============================================
    DataSet.Vc = 299792458; % скорость света в вакууме [м/c]
    DataSet.Vf = NaN;       % скорость ЭМ волн в линии [м/c]
    DataSet.Lx_sum = NaN;    % суммарная протяженность линии [км]
    DataSet.Lx_row = NaN;   % штука нужная !!!
    DataSet.sections = NaN; % число однородных секций
    DataSet.t_ptr = NaN;   % время распространения волн в контрольных точках секций на линии [с]
    DataSet.T_num = 4;      % число периодов основной частоты используемых для расчета ВОМП
    DataSet.T_pts = NaN;    % число точек на период основной частоты сигнала [pts]
    DataSet.f_adc = NaN;    % частота дискретизации АЦП [MHz]
    DataSet.f_sys = 50;     % несущая частота [Hz]    
    DataSet.moment_type = 'kurtosis';   % момент случайной велечены для расчета (kurtosis, skewness)
    DataSet.moment_size = 1200; % ширина окна для расчета коэффициента эксцесса, симметрии [pts]
    DataSet.ck_thr = 20.0;  % уставка для коэффициента эксцесса [о.е.]
    DataSet.cs_thr = 5.0;   % уставка для коэффициента симметрии [о.е.]
    DataSet.DWT_type = 'db4';   % тип функции DWT преобразования
    DataSet.DWT_level = 12;     % уровень разложения DWT преобразования
    DataSet.special_ph = NaN;   % особая фаза (A или B или C)
    DataSet.err_type = NaN;   % вид повреждения (расматриваются только КЗ)
    DataSet.use_mod0 = false;   % использовать нулевой модальный канал для расчета
    DataSet.filt_dir = 'filter\type\'; % директория фильтров IIR, FIR
    DataSet.pfilt_type = 'notused';    % вид функции предварительно фильтрации (dwt, iir, fir, not used)
    DataSet.rt_type = 'thr';   % способ определения времени прихода ЭМ волн (thr, max)


    % построение графиков: ===============================================
    PlotSet.input = true;
    PlotSet.prefilt = true;
    PlotSet.mod = true;
    PlotSet.EMC = true;
    PlotSet.DWT = true;
    PlotSet.IIR = true;
    PlotSet.moment = true;



    % предварительный расчет параметров уставок: =========================
    [ DataSet ] = My_start_preparations( DataSet, UserSet, LineGeometry );

    % загрузка данных: ===================================================
    [MI_beg, MI_end, MU_beg, MU_end, DataSet] = My_file_loader(FileData, UserSet, DataSet);

    % обработка осциллограм ( выбор режима ): ============================
    [MI_beg, MI_end, MU_beg, MU_end, DataSet] = My_model_selector(MI_beg, MI_end, MU_beg, MU_end, UserSet, DataSet);



    % расчет по каналам напряжения: ======================================
    if (UserSet.use_u)
        disp('Voltage calculation:');
        [ ~ ] = funct_TWFL( MU_beg, MU_end, UserSet, DataSet, FileData, PlotSet );
    end



    % расчет по токовым каналам: =========================================
    if (UserSet.use_i)
        disp('Current calculation:');
        [ ~ ] = funct_TWFL( MI_beg, MI_end, UserSet, DataSet, FileData, PlotSet );
    end
end