%% Load in all .mat files, and save them as netCDF. 

out.lon = 25.5:1:384.5;
out.lat = -89.5:89.5; 
if(0)
 datapath='/data/project1/dclements/Particles/scripts/Flux_Estimates/Flux_1deg/Data/';
  load([datapath,'1deg_clim_May2020.mat']);
 
 out.Area = MLR_struct.surf;
 clear MLR_struct
end

if(0)
 load POC_UVP5_onWOAgrid.mat 
  out.biov_data = get_data('var','biov_tot','shape',1);
  out.slope_data = get_data('var','slope','shape',1);
  clear poc
end

if(0)
 load Ensemble_BV_50.mat
 load Ensemble_SP_50

 for ind = 1:50
 bv_recon(:,:,:,:,ind) = (10.^PredBV_reg(ind).recon) - 0.01;
 sp_recon(:,:,:,:,ind) = PredSp_reg(ind).recon;
 end

 clear PredSp_reg
 clear PredBV_reg

 out.mean_bv_recon = nanmean(bv_recon,5);
 out.mean_sp_recon = nanmean(sp_recon,5);
 out.stdev_bv_recon = nanstd(bv_recon,[],5);
 out.stdev_sp_recon =  nanstd(sp_recon,[],5);
end

if(0)
 load PSD_recon.mat
 out.PSD = PSD;
 clear PSD

 load ../out/Dec_optim.mat
 for ind = 1:50
  flux_tot(:,:,:,:,ind) = Optim(ind).bin3.Flux;
 end
 out.mean_flux = nanmean(flux_tot,5);
 out.stdev_flux = nanstd(flux_tot,[],5);
 clear Optim
 clear flux_tot
end

if(0)
  load('/data/project1/dclements/Particles/scripts/Flux_Estimates/Flux_3D/scripts/out/full_flux_PSD.mat')
 out.PSD_flux = flux_PSD;
 clear flux_PSD 
end

 outpath = '/data/project1/dclements/Particles/scripts/Flux_Estimates/Flux_3D/scripts/Scripts_for_Publish/out/';
 outfile = [outpath,'Global_POC_Export_2024.nc'];

%%% What variables are we actually saving?

    tmpnc.varnames = {'Area','Obs_BV', 'Obs_Slope','Pred_BV','stdev_BV','Pred_slope','stdev_slope','Flux','stdev_flux'};
    tmpnc.dims = {'xy','xyzt','xyzt','xyzt','xyzt','xyzt','xyzt','xyzt','xyzt'};
    tmpnc.sname = {'area','obs_bv','ods_slope','pred_bv','stdev_bv','pred_slope','stdev_slope','flux','stdev_flux'};
    tmpnc.lname = {'Surface Area','Observed Biovolume','Observed Slope','Predicted Biovolume' 'Biovolume Standard Deviation','Predicted Slope','Slope Standard Deviation','POC Flux','Flux Standard Deviation'};
    tmpnc.units = {'m^2' 'ppm' 'unitless' 'ppm' 'ppm' 'unitless' 'unitless' 'mgC/m^2/d' 'mgC/m^2/d'};
    tmpnc.xyzdim = 'woa13';
    CreateNcfile(outfile,tmpnc,'woa13', 'clim', 'lon',out.lon, 'lat', out.lat);
 ncwrite(outfile, 'Area', out.Area');
 ncwrite(outfile, 'Obs_BV', out.biov_data);
 ncwrite(outfile, 'Obs_Slope', out.slope_data);
 ncwrite(outfile, 'Pred_BV', out.mean_bv_recon);
 ncwrite(outfile, 'stdev_BV', out.stdev_bv_recon);
 ncwrite(outfile, 'Pred_slope', out.mean_sp_recon);
 ncwrite(outfile, 'stdev_slope', out.stdev_sp_recon);
 ncwrite(outfile, 'Flux', out.mean_flux);
 ncwrite(outfile, 'stdev_flux', out.stdev_flux);

 % Write the PSD and PSD_flux to NC file
 nccreate(outfile,'out.PSD')
 nccreate(outfile,'out.PSD_flux')

