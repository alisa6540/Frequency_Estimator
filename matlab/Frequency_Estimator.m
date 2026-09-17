%-- Log from MATLAB Model.

if_input = round(out.if_in.data(1:12800).*2^13);
I_Signal = round(out.I_sig.data(1:12800).*2^13);
Q_Signal = round(out.Q_sig.data(1:12800).*2^13);
sqrt_sig = round(out.sqrt_out.data(1:12800).*2^13);
I_Dn = round(out.I_Down.data(1:12800).*2^13);
Q_Dn = round(out.Q_Down.data(1:12800).*2^13);
% Noise_Mean_sig = round(out.Noise_Mean.data(2:12800).*2^13);
Freq_Estim_sig = round(out.Freq_Estimated.data(1:end).*2^13);
FFT_out_sig = round(out.FFT_out.data(1:12800).*2^13);
FFT_Re_sig = round(out.FFT_Re.data(1:12800).*2^13);


file_Input_Signal1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\IF_Input.txt','w');
file_Input_Signal2 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\I_Sig.txt','w');
file_Input_Signal3 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Q_Sig.txt','w');
file_Input_Signal4 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\sqrt_Sig.txt','w');
file_Input_Signal5 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\I_Dn.txt','w');
file_Input_Signal6 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Q_Dn.txt','w');
% file_Input_Signal7 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Noise_Mean_sig.txt','w');
file_Input_Signal8 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Freq_Estim_sig.txt','w');
file_Input_Signal9 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_out_sig.txt','w');
file_Input_Signal10 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_Re_sig.txt','w');

for i = 1:length(if_input)
    fprintf(file_Input_Signal1,'%d\r\n',if_input(i));
    fprintf(file_Input_Signal2,'%d\r\n',I_Signal(i));
    fprintf(file_Input_Signal3,'%d\r\n',Q_Signal(i));
    fprintf(file_Input_Signal4,'%d\r\n',sqrt_sig(i));
    fprintf(file_Input_Signal5,'%d\r\n',I_Dn(i));
    fprintf(file_Input_Signal6,'%d\r\n',Q_Dn(i));
    % fprintf(file_Input_Signal7,'%d\r\n',Noise_Mean_sig(i));
    fprintf(file_Input_Signal9,'%d\r\n',FFT_out_sig(i));
    fprintf(file_Input_Signal10,'%d\r\n',FFT_Re_sig(i));
    if i <= length(Freq_Estim_sig)
        % fprintf(file_Input_Signal8,'%d\r\n',Freq_Estim_sig(i));
    end;
end;

fclose(file_Input_Signal1);
fclose(file_Input_Signal2);
fclose(file_Input_Signal3);
fclose(file_Input_Signal4);
fclose(file_Input_Signal5);
fclose(file_Input_Signal6);
% fclose(file_Input_Signal7);
fclose(file_Input_Signal8);
fclose(file_Input_Signal9);
fclose(file_Input_Signal10);

%%

%-- Log from MATLAB Model and VHDL simulation.

% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\IF_Input.txt');
% IF_Input_Sig = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\I_Sig.txt');
% I_Sig_Matlab = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\I_Sign_HDL.txt');
% I_Sig_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Q_Sig.txt');
% Q_Sig_Matlab = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\I_dem_HDL.txt');
% I_dem_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Q_dem_HDL.txt');
% Q_dem_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Q_Sign_HDL.txt');
% Q_Sig_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);

% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\I_Dn.txt');
% I_Down = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\I_Dn_HDL.txt');
% I_Dn_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\sqrt_Sig.txt');
% sqrt_Sig = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\SQRT_HDL.txt');
% SQRT_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Noise_Mean_sig.txt');
% Noise_Mean = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Noise_Mean_HDL.txt');
% Noise_Mean_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_Amp_HDL.txt');
% FFT_Amp_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);

% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_Output_Index_HDL.txt');
% FFT_Output_Index_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);

% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Freq_Estim_HDL.txt');
% Freq_Estim_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\Freq_Estim_sig.txt');
% Freq_Estim_sig = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);

file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_Amp_HDL.txt');
FFT_out_HDL = fscanf(file_Output_Signal_1 , '%d');
fclose(file_Output_Signal_1);

file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_out_sig.txt');
FFT_out_sig = fscanf(file_Output_Signal_1 , '%d');
fclose(file_Output_Signal_1);

% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_Re_HDL.txt');
% FFT_Re_HDL = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);
% % 
% file_Output_Signal_1 = fopen('D:\myProjects\Vhdl\Frequency_Estimator\FFT_Re_sig.txt');
% FFT_Re_sig = fscanf(file_Output_Signal_1 , '%d');
% fclose(file_Output_Signal_1);





% plot(-1*Q_Sig_HDL)
% hold
% plot(Q_Sig_Matlab(17:end), 'r')

% plot(Q_Sig_Matlab(47:end),'r')
% hold
% plot(-1*Q_dem_HDL,'b')
% hold
% plot(-1*I_Sig_Matlab(47:end))
% hold
% plot(I_dem_HDL, 'r')
% hold


plot(FFT_out_HDL, 'b')
hold
plot(FFT_out_sig(1:end), 'r')
hold

% plot(FFT_Re_HDL, 'b')
% hold
% plot(FFT_Re_sig(747:end), 'r')
% hold

% plot(FFT_Re_sig, 'b')
% hold
% plot(FFT_Re_sig, 'r')
% hold

%%
N = 128;

% مقایسه فریم اول
FFT_HDL_frame1 = FFT_Re_HDL(1:N);
FFT_Matlab_frame1 = FFT_Re_sig(1:N);

figure;
plot(FFT_HDL_frame1, 'b'); hold on;
plot(FFT_Matlab_frame1, 'r');
legend('HDL', 'MATLAB');
title('FFT Real - Frame 1');
grid on;

%%
figure
subplot(2,1,1);
plot(Output_Signal_1_14bit);
hold;
plot(floor(node4*2^14),'--r');
title('Signed Output\_Signal\_1\_15bit');
subplot(2,1,2);
plot(floor(node4(1:Samples_N)*2^14)- Output_Signal_1_14bit(1:Samples_N));
title('MatlabFixed minus VHDL');
