function [ ck , ck_abs ] = funct_fft( signal, f_base, f_adc , harm, k_in, inform )
% ������ �� 07.06.2018 v1.2 � ��������������� �����������

% signal - �������� ������ (������)
% win_tipe - ��� ���� ������������� ��� ��������������
% f_base - ������� ������� ������������ �������
% f_adc - ������� ������������� ���
% ck - ����������� ������ ����������� �������� k-��� ��������� �������
% ck_rms - ����������� �������� k-��� ��������� �������

% ������������� ����������
if (strcmp(harm ,'Harm'))
    k = k_in;
else
    k = 1;  % ����� ���������� ���������
end
ck = zeros(size(signal));
ck_abs = zeros(size(signal));
points = int32(f_adc/f_base);  % ������������ ����� ����� �� ������
buffer = 0; % ������ ������������� ��������

for i = 1:1:size(signal,1)
    % ������������� ������������� k-��� ���������
    ak = 0; % �������������� �����
    bk = 0; % ������ �����
    
    % ���������� ������� ���������� �� �������
    if (i < points )
        buffer(1:i,1) = signal(1:i,1);
    else
        buffer(1:points,1) = signal((i - points + 1):1:i,1);
    end
    
    % ����������� ���������� ����� � ������
    Nt = size(buffer,1);
    
    for j = 1:1:Nt
        
        % ����������� ���� ���� ��� ��������������
        win = 1;    % ������������� ����� ����
        
        % ���������� �������������
        ak = ak + win*buffer(j,1)*cos(k*2*pi*(j-1)/Nt);
        bk = bk + win*buffer(j,1)*sin(k*2*pi*(j-1)/Nt);
    end
    
    % ����������� Ck_rms � ck �������� ��� k-��� ��������� �������
    ck_abs(i,1) = sqrt(2*((ak/Nt)^2 + (bk/Nt)^2));
    ck(i,1) = complex(sqrt(2)*ak/Nt,sqrt(2)*bk/Nt);
    
    if (strcmp(inform, 'info'))
        progress = double(i)/double(size(signal,1))*100;
        disp(['Progress: ', progress, ' abs val: ', num2str(ck_abs(i,1))]);
    end
end
end