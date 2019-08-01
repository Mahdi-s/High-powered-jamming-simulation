function [frmError, BPR] = crc(SNR, framelen, msg, interference , M, carrier, transmitFilter)
    numFrames = 1000; 
    
    gen = comm.CRCGenerator('z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1'); % using CRC-32  
    detect = comm.CRCDetector('z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1'); % using CRC-32
    data = msg;                          % Msg represents data created in the main program
    encData = step(gen,data);            % Append CRC bits
    modData = pskmod(encData, M, pi/4);  % psk modulate
    for i = 1:length(SNR)
        chan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)',...
                'SNR',SNR(i),'SignalPower',1);              

        for k = 1:numFrames
            received2 = chan(modData);
            received2 = received2;% + interference(1:1032); %uncomment to add interference to the signal   
            demodData = pskdemod(received2,M);   % BPSK demodulate
            [~,frmError(i,k)] = detect(demodData);  % Detect CRC errors
        end
        %FER(i) = sum(frmError)/numFrames;
    end
    Sum = sum(frmError');
    BPR = Sum/numFrames;   
%plot functions
S = sort(SNR);

figure;
plot(S, frmError)
figure;
plot(S, BPR)
    
end
