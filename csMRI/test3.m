
datapath='/Users/hzeng/Data/hzeng.r52/';
expno=19;
sf = 0;
%function data = readRareFidScale(datapath, expno, sf)
filename=fullfile(datapath, num2str(expno),'fid');
%% read paramters from method file
acqp = fullfile(datapath, num2str(expno),'acqp');
P = readnmrpar(acqp);
FIDSIZE = P.ACQ_size;
NE = P.ACQ_rare_factor;
NS = P.NSLICES;
NR = P.NR;
PHASEENC = P.ACQ_spatial_phase_1;
method = fullfile(datapath, num2str(expno),'method');
P_method = readnmrpar(method);
Nch = P_method.PVM_EncNReceivers;

nx= FIDSIZE(1)/2;
%when fid is not order of 2 Bruker will zero filling fid to order of 2
nx_fid=2^nextpow2(nx);
ny= FIDSIZE(2);
% data in the following order
% [real, imag] x nx_fid x Nch x NE x NS x ny/NE x NR;
dim_acq = [2, nx_fid, Nch, NE, NS, ny/NE, NR];
dim_fid = [2, nx_fid, ny, Nch, NS, NR];
f=fopen(filename,'r','l');
data = fread(f, prod(dim_acq), 'int32');
data = reshape(data, dim_acq);
data = permute(data, [1, 2, 4, 6, 3, 5, 7]);
data = reshape(data, dim_fid);
data = complex(data(1,:,:,:,:,:), data(2,:,:,:,:,:));
data = shiftdim(data);

rf = P.ACQ_rare_factor;
nr = ny / rf;

data = data .* repmat(exp(mod((0:ny-1),rf) * sf),[nx,1]);


%resort the k base based on the phase encoding
[~, idx] = sort(PHASEENC,2,'descend');
data=data(:,idx,:,:,:);

