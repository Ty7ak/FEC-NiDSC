%%%GENERATOR%%%

n_bits = 5000;
rows = 1;
init_bits = randi([0 1], rows, n_bits);

%%%ENCODING%%%%

%tripple bits encoding
triple_bits_encoded = repelem(init_bits, 3);

%hamming encoding
hamming_encoded = encode(init_bits, 7, 4, 'hamming/binary');

%bch encoding
m = 4;
n = 2^m - 1;
k = 5;
bits_k_mtrx = reshape(init_bits, n_bits/k, k);
msgTx = gf(bits_k_mtrx);
bch_encoded = bchenc(msgTx, n, k);

%%%CHANNELS%%%

%getting bch bits for array representation (Gilbert channel)

% uncomment if using Gilbert channel and BCH %
%
mm = 1;
prim_poly = 3;
bch_bits = gf2dec(bch_encoded, mm, prim_poly);
bch_encoded = bch_bits;
%}

%choosing what coding we want to use to transport bits
data = bch_encoded;
%data = hamming_encoded;
%data = triple_bits_encoded;

%BSC

%{

% uncomment if using BSC %

probability = 0.1;
%ndata = bsc(data, probability);

%}

%Gilbert model%

% uncomment if using Gilbert channel %

goodtobad = 0.004;
badtogood = 0.2;
errorwhengood = 0.5;
errorwhenbad = 0.9;
ndata = [];
good_state = true;

for bit = data
    if good_state
        if rand() < errorwhengood
            if bit == 0
                ndata = [ndata, 1];
            else
                ndata = [ndata, 0];
            end
        else
            if bit == 0
                ndata = [ndata, 0];
            else   
                ndata = [ndata, 1];
            end
        end
        
        if rand() < goodtobad
            good_state = false;
        end
        
    else 
        if rand() < errorwhenbad
            if bit == 0
                ndata = [ndata, 1];
            else
                ndata = [ndata, 0];
            end
        else
            if bit == 0
                ndata = [ndata, 0];
            else   
                ndata = [ndata, 1];
            end
        end
        
        if rand() < badtogood
            good_state = true;
        end 
    end 
end

%for bch after Gilbert channel
% uncomment if using Gilbert channel and BCH %

%
bch_bits_mtrx = reshape(ndata, [], n);
ndata = gf(bch_bits_mtrx);
%}

%%%DECODING%%%%

%%%triple bits decoding%%%

% uncomment if using triple bits (any channel) %

%{

zeros = 0;
ones = 0;
decoded_data = [];
for bit = ndata
    if bit == 0
        zeros = zeros + 1;
    else 
        ones = ones +1;
    end
    if zeros + ones == 3
        if zeros > ones
            decoded_data = [decoded_data, 0]; 
        else
            decoded_data = [decoded_data, 1];
        end
        zeros = 0;
        ones = 0;
    end
end
triple_bits_BER = biterr(init_bits, decoded_data)/n_bits
triple_bits_redundancy = numel(triple_bits_encoded)/numel(init_bits)
%}

%%%hamming decoding%%%

% uncomment if using hamming(7,4)(any channel) %

%{
hamming_decoded = decode(ndata, 7, 4, 'hamming/binary');
hamming_BER = biterr(init_bits, hamming_decoded)/n_bits
hamming_redundancy = numel(hamming_encoded)/numel(init_bits)
%}  

%%%bch decoding%%%

% uncomment if using bch (any channel) %

%
bch_decoded = bchdec(ndata, n, k);
bch_bits = gf2dec(bch_decoded, mm, prim_poly);
bch_BER = biterr(bch_bits, init_bits)/n_bits
bch_redundancy = numel(bch_encoded)/numel(init_bits)
%}

%%%%%%%%%%%%%%%%%%%%%%%%

%turning gf array to decimal array
function [DecOutput] = gf2dec(GFInput,m,prim_poly)
GFInput = GFInput(:)';% force a row vector
GFRefArray = gf([0:(2^m)-1],m,prim_poly);
for i=1:length(GFInput)
    for k=0:(2^m)-1
        temp = isequal(GFInput(i),GFRefArray(k+1));
        if (temp==1)
            DecOutput(i) = k;
        end
    end
end
end

