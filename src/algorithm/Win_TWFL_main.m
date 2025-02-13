function [ out ] = Win_TWFL_main( sig_1, sig_2, DS, US )
    % ���������� ��������� ������:
    % ������� ������:
    GS.color.sig_1 = [0.00, 0.45, 0.74];        % ��� ������� 1
    GS.color.sig_2 = [0.85, 0.33, 0.10];        % ��� ������� 2
    GS.color.slr_1 = [1.00, 0.00, 0.00];        % ��� ������ ��������
    GS.color.slr_2 = [0.00, 0.00, 1.00];        % ��� ������� ��������
    GS.color.slr_1_field = [255, 099, 071]/255;
    GS.color.slr_2_field = [135, 206, 250]/255;
    GS.color.btn = [0.94, 0.94, 0.94];          % ����������� ��� ������
    GS.color.mod = [0.30, 0.75, 0.93];          % ��� �������� ������ ������

    GS.color.one_btn = [106, 090, 205]/255;      % ��� ������ �������������� ������
    GS.color.one_field_1 = [123, 104, 238]/255;  % ��� ���� 1 �������������� ������
    GS.color.one_field_2 = [218, 112, 214]/255;  % ��� ���� 2 �������������� ������

    GS.color.double_btn = [034, 139, 034]/255;     % ��� ������ �������������� ������
    GS.color.double_field_1 = [050, 205, 050]/255; % ��� ���� 1 �������������� ������
    GS.color.double_field_2 = [124, 252, 050]/255; % ��� ���� 2 �������������� ������


    % ������������ �������� �� �������:
    if (int32(sig_1.time(1)) < int32(sig_2.time(1)))
        for i = 1:1:sig_1.size
            if ((int32(sig_1.time(i)) == int32(sig_2.time(1))))
                break;
            end
        end
         GS.base_sig_1.time = sig_1.time(i+1:1:end,:);
         GS.base_sig_1.sig = sig_1.sig(i+1:1:end,:);
         GS.base_sig_1.phase = sig_1.phase;
         GS.base_sig_1.size = size(GS.base_sig_1.time,1);

         GS.base_sig_2.time = sig_2.time(1:1:end-i,:);
         GS.base_sig_2.sig = sig_2.sig(1:1:end-i,:);
         GS.base_sig_2.phase = sig_2.phase;
         GS.base_sig_2.size = size(GS.base_sig_2.time,1);
    else
        for i = 1:1:sig_1.size
            if ((int32(sig_1.time(1)) == int32(sig_2.time(i))))
                break;
            end
        end
        GS.base_sig_2.time = sig_2.time(i+1:1:end,:);
        GS.base_sig_2.sig = sig_2.sig(i+1:1:end,:);
        GS.base_sig_2.phase = sig_2.phase;
        GS.base_sig_2.size = size(GS.base_sig_2.time,1);

        GS.base_sig_1.time = sig_1.time(1:1:end-i,:);
        GS.base_sig_1.sig = sig_1.sig(1:1:end-i,:);
        GS.base_sig_1.phase = sig_1.phase;
        GS.base_sig_1.size = size(GS.base_sig_1.time,1);
    end

    % ��������� �������:
    GS.Vc = DS.Vc*US.nc;
    GS.Lx = US.Lx_km;

    % �������������� ���������:
    GS.sig_1 = GS.base_sig_1;
    GS.sig_2 = GS.base_sig_2;

    % ������ ���������� ������:
    GS.mod_idx = 1;    % 1 - modal_1; 2 - modal_2

    clear sig_1 sig_2 DS US;


    % ����� ������������ ����:
    [ handles ] = win_constructor( GS );

%     while true
%         if (~handles)
%             out = true;
%             break;
%         end
%     end
    out = true;
end


% ����������� ���� win_main:
function [ handles ] = win_constructor( GS )

    % �������� ����:
    H = open('Win_TWFL_main.fig');
    handles = guihandles(H);
    guidata(handles.win_main, GS);

    % ��������� �������� 1:
    set(handles.slider1, 'Min', 1.0);
    set(handles.slider1, 'Max', GS.sig_1.size);
    set(handles.slider1, 'Value', 1.0);
    set(handles.slider1,'SliderStep', [1/(GS.sig_1.size-1), 100/(GS.sig_1.size-1)]);
    set(handles.vd_slr1, 'BackgroundColor', GS.color.slr_1);

    % ��������� �������� 2:
    set(handles.slider2, 'Min', 1.0);
    set(handles.slider2, 'Max', GS.sig_2.size);
    set(handles.slider2, 'Value', GS.sig_2.size);
    set(handles.slider2,'SliderStep', [1/(GS.sig_2.size-1), 100/(GS.sig_2.size-1)]);
    set(handles.vd_slr2, 'BackgroundColor', GS.color.slr_2);

    % ��������� �������������� ��������� ����:
    set(handles.e_win_beg, 'String', int32(1));
    set(handles.e_win_end, 'String', int32(GS.sig_1.size));
    set(handles.e_Vc, 'String', GS.Vc);
    set(handles.btn_mod1, 'BackgroundColor', GS.color.mod);
    set(handles.vd_sig1, 'BackgroundColor', GS.color.sig_1);
    set(handles.vd_sig2, 'BackgroundColor', GS.color.sig_2);
    set(handles.vd2_slr1, 'BackgroundColor', GS.color.slr_1);
    set(handles.vd2_slr2, 'BackgroundColor', GS.color.slr_2);

    % ��������� ������:
    set(handles.btn_method, 'BackgroundColor',  GS.color.one_btn);
    set(handles.e_sig1_beg, 'BackgroundColor',  GS.color.one_field_1);
    set(handles.e_sig1_end, 'BackgroundColor',  GS.color.one_field_1);
    set(handles.e_sig2_beg, 'BackgroundColor',  GS.color.one_field_2);
    set(handles.e_sig2_end, 'BackgroundColor',  GS.color.one_field_2);

    % ��������� �����:
    set(handles.e_idx1, 'BackgroundColor', GS.color.slr_1_field);
    set(handles.e_t_beg, 'BackgroundColor', GS.color.slr_1_field);
    set(handles.e_idx2, 'BackgroundColor', GS.color.slr_2_field);
    set(handles.e_t_end, 'BackgroundColor', GS.color.slr_2_field);

    % ��������� ����� � �������:
    [ handles ] = slider_fun( handles );


    % ����������� ��������� �������:
    set(handles.btn_close, 'Callback', { @btn_close_Callback, handles });
    set(handles.btn_mod1, 'Callback', { @btn_mod1_Callback, handles });
    set(handles.btn_mod2, 'Callback', { @btn_mod2_Callback, handles });
    set(handles.btn_refresh, 'Callback', { @btn_refresh_Callback, handles });
    set(handles.btn_method, 'Callback', { @btn_method_Callback, handles });
    set(handles.slider1, 'Callback', { @slider_beg_Callback, handles });
    set(handles.slider2, 'Callback', { @slider_end_Callback, handles });
end


% ������� ��������� �������� � ��������:
function [ handles ] = slider_fun( handles )

    GS = guidata(handles.win_main);
    val_1 = int32(get(handles.slider1, 'Value'));
    val_2 = int32(get(handles.slider2, 'Value'));

    % ��������������� �������� �������:
    set(handles.e_idx1, 'String', val_1);
    set(handles.e_idx2, 'String', val_2);

    % �������������� ����� �������:
    set(handles.e_t_beg, 'String', GS.sig_1.time(val_1,:));
    set(handles.e_t_end, 'String', GS.sig_1.time(val_2,:));
    set(handles.e_dt, 'String', GS.sig_1.time(val_2,:) - GS.sig_1.time(val_1,:));

    % ������ ��������� �� ����� ����������:
    [ ~ ] = distans_fun( handles, GS );

    % ��������������� �������� �������� 1:
    set(handles.e_sig1_beg, 'String', GS.sig_1.sig(val_1, GS.mod_idx));
    set(handles.e_sig2_beg, 'String', GS.sig_2.sig(val_1, GS.mod_idx));

    % ��������������� �������� �������� 2:
    set(handles.e_sig1_end, 'String', GS.sig_1.sig(val_2, GS.mod_idx));
    set(handles.e_sig2_end, 'String', GS.sig_2.sig(val_2, GS.mod_idx));

    % ��������������� �������� �� ����:
    cla(handles.axes_main); % ������� ����

    LW_mark = 2.5;  % ������ �������
    LW_line = 1.2;  % ������� �����
    T_mark = '.';   % ��� �������

    hold(handles.axes_main, 'on');
    plot(handles.axes_main, GS.sig_1.sig(:,GS.mod_idx), 'LineWidth', LW_line, 'color', GS.color.sig_1);
    plot(handles.axes_main, GS.sig_2.sig(:,GS.mod_idx), 'LineWidth', LW_line, 'color', GS.color.sig_2);

    % ��������� �������� 1:
    plot(handles.axes_main, [val_1, val_1], [min(handles.axes_main.YTick),  max(handles.axes_main.YTick)], 'color', GS.color.slr_1);
    plot(handles.axes_main, val_1, GS.sig_1.sig(val_1, GS.mod_idx), 'Marker', T_mark, 'LineWidth', LW_mark, 'color', GS.color.slr_1);
    plot(handles.axes_main, val_1, GS.sig_2.sig(val_1, GS.mod_idx), 'Marker', T_mark, 'LineWidth', LW_mark, 'color', GS.color.slr_1);

    % ��������� �������� 2:
    plot(handles.axes_main, [val_2, val_2], [min(handles.axes_main.YTick),  max(handles.axes_main.YTick)], 'color', GS.color.slr_2);
    plot(handles.axes_main, val_2, GS.sig_2.sig(val_2, GS.mod_idx), 'Marker', T_mark, 'LineWidth', LW_mark, 'color', GS.color.slr_2);
    plot(handles.axes_main, val_2, GS.sig_2.sig(val_2, GS.mod_idx), 'Marker', T_mark, 'LineWidth', LW_mark, 'color', GS.color.slr_2);
    hold(handles.axes_main, 'off');

    xlabel(handles.axes_main, '������, pts');
    ylabel(handles.axes_main, '���������, �.�.');
    xlim(handles.axes_main, [1, GS.sig_1.size]);
%    set(handles.axes_main, 'XTickLabel', int32(GS.sig_1.time));
    guidata(handles.win_main, GS);
end


% ������ ��������� �� ����� ����������:
function [ handles ] = distans_fun( handles, GS )

    val_1 = int32(get(handles.slider1, 'Value'));
    val_2 = int32(get(handles.slider2, 'Value'));
    dt = (GS.sig_1.time(val_2,:) - GS.sig_1.time(val_1,:));

    if (~get(handles.btn_method, 'Value'))
        Lx = (0.5*GS.Vc*1e-12)*dt;
    else
        Lx = 0.5*(GS.Lx - (GS.Vc*1e-12)*dt);
    end
    set(handles.e_Lx, 'String', Lx);
end


% ��������� ������ close:
function btn_close_Callback( hObject, evt, handles )

    delete(handles.win_main);
end


% ��������� ������ method:
function btn_method_Callback( hObject, evt, handles )

    GS = guidata(handles.win_main);
    if (get(hObject, 'Value'))
        set(hObject, 'String', 'double-sided');
        set(hObject, 'BackgroundColor', GS.color.double_btn);
        set(handles.e_sig1_beg, 'BackgroundColor',  GS.color.double_field_1);
        set(handles.e_sig2_end, 'BackgroundColor',  GS.color.double_field_1);
        set(handles.e_sig1_end, 'BackgroundColor',  GS.color.double_field_2);
        set(handles.e_sig2_beg, 'BackgroundColor',  GS.color.double_field_2);
    else
        set(hObject, 'String', 'one-sided');
        set(hObject, 'BackgroundColor',  GS.color.one_btn);
        set(handles.e_sig1_beg, 'BackgroundColor',  GS.color.one_field_1);
        set(handles.e_sig1_end, 'BackgroundColor',  GS.color.one_field_1);
        set(handles.e_sig2_beg, 'BackgroundColor',  GS.color.one_field_2);
        set(handles.e_sig2_end, 'BackgroundColor',  GS.color.one_field_2);
    end

    % ������ ��������� �� ����� ����������:
    [ ~ ] = distans_fun( handles, GS );
end


% ��������� ������ refresh:
function btn_refresh_Callback( hObject, evt, handles)

    win_beg = int32(str2double(get(handles.e_win_beg, 'String')));
    win_end = int32(str2double(get(handles.e_win_end, 'String')));

    if ( win_beg < win_end && (win_beg || win_end))
        GS = guidata(handles.win_main);

        % ��������������� ��������� ��������:
        GS.sig_1.sig = GS.sig_1.sig(win_beg:1:win_end,:);
        GS.sig_1.time = GS.sig_1.time(win_beg:1:win_end,:);
        GS.sig_1.phase = GS.sig_1.phase;
        GS.sig_1.size = size(GS.sig_1.time,1);

        GS.sig_2.sig = GS.sig_2.sig(win_beg:1:win_end,:);
        GS.sig_2.time = GS.sig_2.time(win_beg:1:win_end,:);
        GS.sig_2.phase = GS.sig_2.phase;
        GS.sig_2.size = size(GS.sig_2.time,1);

        guidata(handles.win_main, GS);

        % ��������� �������� 1:
        set(handles.slider1, 'Min', 1.0);
        set(handles.slider1, 'Max', GS.sig_1.size);
        set(handles.slider1, 'Value', 1.0);
        set(handles.slider1, 'SliderStep', [1/(GS.sig_1.size-1), 100/(GS.sig_1.size-1)]);

        % ��������� �������� 2:
        set(handles.slider2, 'Min', 1.0);
        set(handles.slider2, 'Max', GS.sig_2.size);
        set(handles.slider2, 'Value', GS.sig_2.size);
        set(handles.slider2, 'SliderStep', [1/(GS.sig_2.size-1), 100/(GS.sig_2.size-1)]);

        % ��������� ����� win:
        set(handles.e_win_beg, 'String', 1);
        set(handles.e_win_end, 'String', GS.sig_1.size);

        % ��������� ����� � �������:
        [ ~ ] = slider_fun( handles );

    elseif (~win_beg || ~win_end)
        GS = guidata(handles.win_main);
        GS.sig_1 = GS.base_sig_1;
        GS.sig_2 = GS.base_sig_2;
        guidata(handles.win_main, GS);

        % ��������� �������� 1:
        set(handles.slider1, 'Min', 1.0);
        set(handles.slider1, 'Max', GS.sig_1.size);
        set(handles.slider1, 'Value', 1.0);
        set(handles.slider1, 'SliderStep', [1/(GS.sig_1.size-1), 100/(GS.sig_1.size-1)]);

        % ��������� �������� 2:
        set(handles.slider2, 'Min', 1.0);
        set(handles.slider2, 'Max', GS.sig_1.size);
        set(handles.slider2, 'Value', GS.sig_1.size);
        set(handles.slider2,'SliderStep', [1/(GS.sig_1.size-1), 100/(GS.sig_1.size-1)]);

        % ��������� ����� win:
        set(handles.e_win_beg, 'String', 1);
        set(handles.e_win_end, 'String', GS.sig_1.size);

        % ��������� ����� � �������:
        [ ~ ] = slider_fun( handles );
    end
end


% ������������ ��������� ������� mod 1:
function btn_mod1_Callback( hObject, evt, handles)

    GS = guidata(handles.win_main);
    if (GS.mod_idx ~= 1)
        GS.mod_idx = 1;
        guidata(handles.win_main, GS);
        set(handles.btn_mod2, 'BackgroundColor', GS.color.btn);
        set(hObject, 'BackgroundColor', GS.color.mod);

        % ��������� ����� � �������:
        [ ~ ] = slider_fun( handles );
    end
end


% ������������ ��������� ������� mod 2:
function btn_mod2_Callback( hObject, evt, handles)

    GS = guidata(handles.win_main);
    if (GS.mod_idx ~= 2)
        GS.mod_idx = 2;
        guidata(handles.win_main, GS);
        set(handles.btn_mod1, 'BackgroundColor', GS.color.btn);
        set(hObject, 'BackgroundColor', GS.color.mod);

        % ��������� ����� � �������:
        [ ~ ] = slider_fun( handles );
    end
end


% ��������� �������� begin:
function slider_beg_Callback( hObject, evt, handles)

    % ��������� ����� � �������:
    [ ~ ] = slider_fun( handles );
end


% ��������� �������� end:
function slider_end_Callback( hObject, evt, handles)

    % ��������� ����� � �������:
    [ ~ ] = slider_fun( handles );
end