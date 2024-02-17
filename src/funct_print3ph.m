function [ ] = funct_print3ph( Sig_beg, Sig_end, SL )

    xl = 'индекс, точки';
    yl = 'амплитуда, о. е.';
    line_width = 1.5;
    
    figure;
    subplot(2,1,1);
    plot(Sig_beg.sig, 'LineWidth', line_width);
    grid minor;
    xlabel(xl);
    ylabel(yl);
    title(SL.title_beg);
    legend(SL.legend_beg);

    subplot(2,1,2);
    plot(Sig_end.sig, 'LineWidth', line_width);
    grid minor;
    xlabel(xl);
    ylabel(yl);
    title(SL.title_end);
    legend(SL.legend_end);
end