function [x flux_tot dpth stats] = find_dep_optim(PSD,optim_flux,depth,varargin)
   
   A.reconstruct = 1;
   A.bins = 3;
   A.random = 1;
   A = parse_pv_pairs(A, varargin);

% Set up bins
   smin = 35*10^-6;    % meters
   smax = 5*10^-3;   % meters
   bin_vec = logspace(log10(smin),log10(smax),21);

% Make sbnd -- Same as in parpool
   sbnd(:,1) = bin_vec(1:end-1);
   sbnd(:,2) = bin_vec(2:end);
   sctr = nanmean(sbnd,2);
   swdt = sbnd(:,2) - sbnd(:,1);

   nbins = A.bins;
   options = optimset('display','off');
   x0 = nan(nbins,2);

 % Starts with random initial guesses (for testing robustness)
      x0(:,1) = rand(nbins,1) * 25 + 25;
      x0(:,2) = rand(nbins,1) + 2;

 % Unfolds x0 to a vector with intercept,slope,intercept,slope ...
   tmp = x0';
   x0=tmp(:);

   tpp = [];
   flux_tot = [];
   dpth = logspace(log10(20),log10(2100),nbins);
   dpth(2:end-1) = normrnd(dpth(2:end-1),100);
   idx = findin(dpth,depth);

% Initialize stats   
   stats.SSE = nan;
   stats.MSE = nan;
   stats.RMSE = nan;
   stats.SSR = nan;
   stats.SST = nan;
   stats.R2 = nan;

   optim_flux = optim_flux(:,:,1:67,:,:);
   ub = ones(length(x0),1);
   lb = zeros(length(x0),1);;
   for id = 1:length(x0); 
   if rem(ub(id,1),2)==1
   ub(id,1) = 1000;
   else
   ub(id,1) = 10;
   end 
   end
   [x_1 fval_1] = fmincon(@costfun_linear,x0,[],[],[],[],lb,ub,[],options);
   x = x_1;
   fval = fval_1;

   if A.reconstruct ==1

   int_z = ones(1,67) * x(1);
   sp_z  = ones(1,67) * x(2);

   for id = 1:nbins-1
      for ind = idx(id):idx(id+1)-1
         idd = id * 2 - 1;
         int_z(ind) = x(idd) + (depth(ind) - depth(idx(id))) / ...
                      (depth(idx(id+1)) - depth(idx(id))) * (x(idd+2) - x(idd));
         sp_z(ind)  = x(idd+1) + (depth(ind) - depth(idx(id))) / ...
                    (depth(idx(id+1)) - depth(idx(id))) * (x((idd+3)) - x((idd+1)));
       end
   end

   z_flux = ((int_z.*(sctr*100).^sp_z) .*(swdt*100))';
   z_flux = reshape(z_flux, [1 1 67 1 20]);
   flux = nansum(PSD(:,:,1:67,:,:).*z_flux *10^3,5);
   flux(flux==0) = nan;
   flux_tot = flux;
   optim = optim_flux;
   id_rem = unique([find(isnan(optim));find(flux==0); find(isnan(flux))]);
   flux(id_rem) = [];
   optim(id_rem) = [];

   stats.SSE = sum((log10(optim(:))-log10(flux(:))).^2);
   stats.MSE = stats.SSE./length(optim);
   stats.RMSE = (stats.MSE).^0.5;
   stats.SSR = sum((log10(flux(:))-nanmean(log10(optim(:)))).^2);
   stats.SST = stats.SSE + stats.SSR;
   stats.R2 = 1.0 - stats.SSE./stats.SST;

   end

   function f = costfun_linear(x)
% Vary the three different points and interpolate over all depths
    int_z0 = ones(1,67) * x(1);
    sp_z0  = ones(1,67) * x(2);
    for id0 = 1:nbins-1
       for ind0 = idx(id0):idx(id0+1)-1
          idd = id0 * 2 - 1;
          int_z0(ind0) = x(idd) + (depth(ind0) - depth(idx(id0))) / ...
                       (depth(idx(id0+1)) - depth(idx(id0))) * (x(idd+2) - x(idd));
          sp_z0(ind0)  = x(idd+1) + (depth(ind0) - depth(idx(id0))) / ...
                       (depth(idx(id0+1)) - depth(idx(id0))) * (x((idd+3)) - x((idd+1)));
       end
    end
    z_flux0 = ((int_z0.*(sctr*100).^sp_z0).*(swdt*100))';
    z_flux0 = reshape(z_flux0, [1 1 67 1 20]);
    flux0 = nansum(PSD(:,:,1:67,:,:).*z_flux0*10^3,5);
    optim0 = optim_flux;
    id_rem0 = unique([find(isnan(optim0));find(flux0==0); find(isnan(flux0))]);
    flux0(id_rem0) = [];
    optim0(id_rem0) = [];
    SSE0 = sum((log10(optim0(:)) - log10(flux0(:))).^2);
    f = SSE0;
   end

end
