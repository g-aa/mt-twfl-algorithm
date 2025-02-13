function [ ] = Main_TWFL( )

    % revision: 24.12.2018

    % Sig = struct('type', [], 'phase', [], 'size', [], 'time', [], 'sig', []);


    % ��������� ����� �������������: =====================================
    FileData.folder = 'oscillograms\fff_MHz\type\';
    FileData.fname = 'signals_Lx_lll_km_s1_type_xxx_km_DorM_Fadc_fff_MHz_dLx_dddd_m_ode.txt';
    FileData.Lx = 100;          % ������������� ����� [��]
    FileData.k_type = 'ABC';    % ��� �����������
    FileData.S1_kx = 31;        % ��������� �� ����� ����������� [��]
    FileData.DM = 'D';          % ��� ����������� (D - ����, M - ������������� ��)
    FileData.MHz = 4.0;         % ������� ������������� [�Hz]
    FileData.dLx = 500;         % ��� ������������� �� x [�]
    FileData.ode_type = 'ode23t';   % ��� �������� ���������
    FileData.dB = NaN;           % ������� ���� � �������� ������� [��]


    % ��������� ��� ���������: ===========================================
    UserSet.U_nom = 110;    % ����������� ���������� ����� [�]
    UserSet.I_nom = 150;    % ����������� ��� ����� [�]
    UserSet.section_Lx = FileData.Lx;   % ������������ ���������� ������ [��]
    UserSet.section_nc = 1.000; % ����������� ����������� �������� ����� � ����� ��� ������
    UserSet.Iu_thr = 2.5;   % ������� ������������� �������� ���� [�.�.]
    UserSet.Ul_thr = 0.85;   % ������� ������������ ���� ���������� [�.�.]
    UserSet.use_i = true;   % ������������ ��� ��� ������� ����
    UserSet.use_u = true;   % ������������ ���������� ��� ������� ����
    UserSet.EMC_use = false;    % ������ �� ������ ��������� ������������
    UserSet.DWT_use = false;    % ������ �� ������ DWT ��������������
    UserSet.IIR_use = true;    % ������ �� ������ �� IIR �������� 
    UserSet.speed_type = false;  % ��� �������� ( false - �������� ����� � �������; true - �������� �������������� � �����/����� )
    UserSet.matrix_type = false; % ��� ������� �������� ( false - �����; true - ���� ��������� ��� )


    % �������������� ��������� ����� ��� (��� ����������� �������):=======
    LineGeometry.Xl = [ -02.1; +04.2; +02.1 ];   % X - ���������� �� ����������� �� ������ ����� �� ������� [ � ]
    LineGeometry.Yl = [ +19.0; +19.0; +23.0 ];   % Y - ������ ������� ������� [ � ]
    LineGeometry.dp = 15.2;     % ������� ������� ��-120/19 [ �� ]
    LineGeometry.Rp = 0.2440;   % ��������� ������������� ������� ��-120/19 [ ��/�� ]
    LineGeometry.np = 1;        % ����� �������� � ����
    LineGeometry.dPk = 0.08;    % ������������� ������ �� ������ ��� �� 110 �� [ ���/�� ]
    LineGeometry.Dz = 1000;     % ������� ��������� �������������� ��������� ������� � ����� [ � ]
    LineGeometry.N_ph = 3;      % ����� ���


    % ��������� ���������: ===============================================
    DataSet.Vc = 299792458; % �������� ����� � ������� [�/c]
    DataSet.Vf = NaN;       % �������� �� ���� � ����� [�/c]
    DataSet.Lx_sum = NaN;    % ��������� ������������� ����� [��]
    DataSet.Lx_row = NaN;   % ����� ������ !!!
    DataSet.sections = NaN; % ����� ���������� ������
    DataSet.t_ptr = NaN;   % ����� ��������������� ���� � ����������� ������ ������ �� ����� [�]
    DataSet.T_num = 4;      % ����� �������� �������� ������� ������������ ��� ������� ����
    DataSet.T_pts = NaN;    % ����� ����� �� ������ �������� ������� ������� [pts]
    DataSet.f_adc = NaN;    % ������� ������������� ��� [MHz]
    DataSet.f_sys = 50;     % ������� ������� [Hz]    
    DataSet.moment_type = 'kurtosis';   % ������ ��������� �������� ��� ������� (kurtosis, skewness)
    DataSet.moment_size = 1200; % ������ ���� ��� ������� ������������ ��������, ��������� [pts]
    DataSet.ck_thr = 20.0;  % ������� ��� ������������ �������� [�.�.]
    DataSet.cs_thr = 5.0;   % ������� ��� ������������ ��������� [�.�.]
    DataSet.DWT_type = 'db4';   % ��� ������� DWT ��������������
    DataSet.DWT_level = 12;     % ������� ���������� DWT ��������������
    DataSet.special_ph = NaN;   % ������ ���� (A ��� B ��� C)
    DataSet.err_type = NaN;   % ��� ����������� (�������������� ������ ��)
    DataSet.use_mod0 = false;   % ������������ ������� ��������� ����� ��� �������
    DataSet.filt_dir = 'filter\type\'; % ���������� �������� IIR, FIR
    DataSet.pfilt_type = 'notused';    % ��� ������� �������������� ���������� (dwt, iir, fir, not used)
    DataSet.rt_type = 'thr';   % ������ ����������� ������� ������� �� ���� (thr, max)


    % ���������� ��������: ===============================================
    PlotSet.input = true;
    PlotSet.prefilt = true;
    PlotSet.mod = true;
    PlotSet.EMC = true;
    PlotSet.DWT = true;
    PlotSet.IIR = true;
    PlotSet.moment = true;



    % ��������������� ������ ���������� �������: =========================
    [ DataSet ] = My_start_preparations( DataSet, UserSet, LineGeometry );

    % �������� ������: ===================================================
    [MI_beg, MI_end, MU_beg, MU_end, DataSet] = My_file_loader(FileData, UserSet, DataSet);

    % ��������� ����������� ( ����� ������ ): ============================
    [MI_beg, MI_end, MU_beg, MU_end, DataSet] = My_model_selector(MI_beg, MI_end, MU_beg, MU_end, UserSet, DataSet);



    % ������ �� ������� ����������: ======================================
    if (UserSet.use_u)
        disp('Voltage calculation:');
        [ ~ ] = funct_TWFL( MU_beg, MU_end, UserSet, DataSet, FileData, PlotSet );
    end



    % ������ �� ������� �������: =========================================
    if (UserSet.use_i)
        disp('Current calculation:');
        [ ~ ] = funct_TWFL( MI_beg, MI_end, UserSet, DataSet, FileData, PlotSet );
    end
end