clc; clear; close all;

%% 1. SELECT IMAGE
[file,path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp','Image Files'});
if isequal(file,0), return; end

img = imread(fullfile(path,file));

figure; imshow(img);
title('Step 1: Original Color Image');

%% 2. GRAYSCALE IMAGE
if size(img,3)==3
    gray_img = rgb2gray(img);
else
    gray_img = img;
end

figure; imshow(gray_img);
title('Step 2: Grayscale Image');

%% 3. PIXEL VALUES
pixel_data = gray_img(:);

fprintf('\n===== STEP 3: PIXEL VALUES =====\n');
fprintf('Total pixels: %d\n',length(pixel_data));
fprintf('Min pixel: %d | Max pixel: %d\n', ...
    min(pixel_data),max(pixel_data));
disp('First 20 pixels:');
disp(pixel_data(1:20).');

%% 4. BINARY CONVERSION
binaryString = dec2bin(pixel_data,8);
binaryData = binaryString - '0';

fprintf('\n===== STEP 4: BINARY CONVERSION =====\n');

idx = find(pixel_data>0,10);

for i=1:length(idx)
    fprintf('Pixel %d = %d --> %s\n', ...
        idx(i),pixel_data(idx(i)),binaryString(idx(i),:));
end

%% 5. BIT STREAM
tx_bits = reshape(binaryData.',1,[]);
originalBitLength = length(tx_bits);

fprintf('\n===== STEP 5: BIT STREAM =====\n');
fprintf('Total bits: %d\n',originalBitLength);
disp('First 50 bits:');
disp(tx_bits(1:50));

%% 6. CHANNEL WITHOUT ERROR CORRECTION
errorProbability = 0.01;

errorMask = rand(size(tx_bits)) < errorProbability;
rx_uncoded = xor(tx_bits,errorMask);

fprintf('\n===== STEP 6: NO ERROR CORRECTION =====\n');
fprintf('Errors introduced: %d\n',sum(errorMask));

% Reconstruct corrupted image
powersOf2 = 2.^(7:-1:0);

receivedBytes = reshape(rx_uncoded,8,[]).';
receivedVector = receivedBytes * powersOf2.';
receivedImage = reshape(uint8(receivedVector),size(gray_img));

figure; imshow(receivedImage);
title('Step 6: Received Image Without Error Correction');

%% 7. PREPARE HAMMING DATA
padding = mod(4-mod(originalBitLength,4),4);
tx_padded = [tx_bits zeros(1,padding)];

dataBlocks = reshape(tx_padded,4,[]).';

fprintf('\n===== STEP 7: HAMMING INPUT =====\n');
fprintf('4-bit blocks: %d\n',size(dataBlocks,1));
disp('First 5 blocks:');
disp(dataBlocks(1:5,:));

%% 8. HAMMING (7,4) ENCODING
N = size(dataBlocks,1);
encodedBits = zeros(N,7);

for i=1:N
    
    d = dataBlocks(i,:);
    
    p1 = mod(d(1)+d(2)+d(4),2);
    p2 = mod(d(1)+d(3)+d(4),2);
    p3 = mod(d(2)+d(3)+d(4),2);
    
    encodedBits(i,:) = [p1 p2 d(1) p3 d(2) d(3) d(4)];
end

fprintf('\n===== STEP 8: HAMMING ENCODING =====\n');
disp('First 5 encoded blocks:');
disp(encodedBits(1:5,:));

%% 9. TRANSMISSION THROUGH NOISY CHANNEL
errorMask = rand(size(encodedBits)) < errorProbability;
rx_encoded = xor(encodedBits,errorMask);

fprintf('\n===== STEP 9: CHANNEL =====\n');
fprintf('Errors introduced: %d\n',sum(errorMask(:)));

%% 10. HAMMING DECODING
decodedBits = zeros(N,4);
corrected = 0;

for i=1:N
    
    r = rx_encoded(i,:);
    
    s1 = mod(r(1)+r(3)+r(5)+r(7),2);
    s2 = mod(r(2)+r(3)+r(6)+r(7),2);
    s3 = mod(r(4)+r(5)+r(6)+r(7),2);
    
    pos = s1 + 2*s2 + 4*s3;
    
    if pos>0
        r(pos) = 1-r(pos);
        corrected = corrected+1;
    end
    
    decodedBits(i,:) = r([3 5 6 7]);
end

fprintf('\n===== STEP 10: ERROR CORRECTION =====\n');
fprintf('Corrected codewords: %d\n',corrected);

%% 11. RECONSTRUCT CORRECTED IMAGE
decodedStream = reshape(decodedBits.',1,[]);
decodedStream = decodedStream(1:originalBitLength);

decodedBytes = reshape(decodedStream,8,[]).';
decodedVector = decodedBytes * powersOf2.';

reconstructedImage = reshape( ...
    uint8(decodedVector),size(gray_img));

figure; imshow(reconstructedImage);
title('Step 11: Image After Hamming Error Correction');

%% 12. BER
BER_without = mean(tx_bits ~= rx_uncoded);
BER_with = mean(tx_bits ~= decodedStream);

fprintf('\n===== STEP 12: BER =====\n');
fprintf('BER without correction: %.6f\n',BER_without);
fprintf('BER with correction: %.6f\n',BER_with);

%% 13. MSE AND PSNR
mse_without = mean( ...
    (double(gray_img(:))-double(receivedImage(:))).^2);

mse_with = mean( ...
    (double(gray_img(:))-double(reconstructedImage(:))).^2);

if mse_without==0
    psnr_without=Inf;
else
    psnr_without=10*log10(255^2/mse_without);
end

if mse_with==0
    psnr_with=Inf;
else
    psnr_with=10*log10(255^2/mse_with);
end

fprintf('\n===== STEP 13: IMAGE QUALITY =====\n');
fprintf('MSE without correction: %.4f\n',mse_without);
fprintf('MSE with correction: %.4f\n',mse_with);

fprintf('PSNR without correction: %.2f dB\n',psnr_without);
fprintf('PSNR with correction: %.2f dB\n',psnr_with);
