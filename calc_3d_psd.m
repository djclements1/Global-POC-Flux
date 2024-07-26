if(0)
 load Ensemble_BV_50.mat
 load Ensemble_SP_50

 for ind = 1:50
 bv_recon(:,:,:,:,ind) = (10.^PredBV_reg(ind).recon) - 0.01;
 sp_recon(:,:,:,:,ind) = PredSp_reg(ind).recon;
 end
 clear PredSp_reg
 clear PredBV_reg
end
   for ind = 1:50
   smin = 102*10^-4;
   smax = 5.2*10^-1;
   int_prediction(:,:,:,:,ind) = (6.*(bv_recon(:,:,:,:,ind)*10^-3)./pi) .* ((smax.^(4-sp_recon(:,:,:,:,ind))./(4-sp_recon(:,:,:,:,ind)))- (smin.^(4-sp_recon(:,:,:,:,ind))./(4-sp_recon(:,:,:,:,ind)))).^-1;
   int_prediction(:,:,:,:,ind) = log10(int_prediction(:,:,:,:,ind));
   end

   PSD_month = nan(360,180,102,20,50);
   PSD = nan(360,180,102,20,12);

   smin = 35*10^-6;    % meters
   smax = 5*10^-3;   % meters
   num_lon = 360;
   num_lat = 180;
   %%% Size binning
   bin_vec = logspace(log10(smin),log10(smax),21);
   sbnd(:,1) = bin_vec(1:end-1);
   sbnd(:,2) = bin_vec(2:end);
   sctr = (sbnd(:,2) + sbnd(:,1)) /2;
   swdt = (sbnd(:,2) - sbnd(:,1));

   for idx = 1:12
   for ind = 1:50
     slopepred_month = sp_recon(:,:,:,idx,ind);
     intpred_month = int_prediction(:,:,:,idx,ind);
     intercept = reshape(intpred_month,([360,180,102,1]));
     slope = reshape(slopepred_month,([360,180,102,1]));
     sctr = reshape(sctr,([1,1,1,20]));
     PSD_month(:,:,:,:,ind) = (10.^intercept) .* (sctr*100).^ -abs(slope);
   end
   PSD(:,:,:,:,idx) = nanmean(PSD_month,5);
   end
   PSD = permute(PSD,[1,2,3,5,4]);


   
