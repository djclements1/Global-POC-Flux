 if(1)
 load('/data/project1/dclements/Particles/scripts/Flux_Estimates/Flux_3D/scripts/out/Gridded_mouw');

 mouw.flux(mouw.flux<=0) = nan;
 optim_flux = mouw.flux;
 optim_flux(optim_flux<=0) = nan;

 %% Now load in etopo and try to remove any obs with bot_depth <100m of trap depth (BBNL range from 50-1000m)
  load WOA_grid.mat;
  top.path = 'etopo2.nc';
  top.lon = ncread(top.path,'x');
  top.lat = ncread(top.path,'y');
  top.var = 'topo';
  top.val = ncread(top.path,top.var);
  tmptopo = smooth2a_cyclic(top.val,16);
  topo = inpaint_nans_bc(interp2_cyclic(top.lon,top.lat,tmptopo,wcoord.LON,wcoord.LAT,'cubic')',4)';
  topo = repmat(topo,1,1,12)*-1; % make positive
  topo(topo<0)=0; % Remove "negative" elevation
  top_lon = -179.5:179.5;
  tmp = find(top_lon<25);
  for ind = 1:12
  topo(:,:,ind) = cat(1,topo(max(tmp)+1:end,:,ind),...
                      topo(1:max(tmp),:,ind));
  end

  depthbnds=[wcoord.depth(1:end-1) wcoord.depth(2:end)];
  depth = nanmean(depthbnds',2);

  for ind = 1:360
   for indj = 1:180
    for indm = 1:12
    bot_depth = topo(ind,indj,indm) - 100;
    tpp = findin(bot_depth,depth);
    optim_flux(ind,indj,tpp:end,indm) = nan;
    end
   end
  end
 clear mouw
 end

 load('PSD_recon.mat')
 PSD = permute(PSD, [1 2 3 5 4]); 

if(1)
 for idd = 1:50
 disp('Performing Linear interp Optimization')
 [params flux dpth stats] = linear_z_optim(PSD,optim_flux,depth,'bins',3);
 param(:,1) = [params(1),params(3),params(5)];
 param(:,2) = [params(2),params(4),params(6)];
 Optim(idd).bin3.Flux = flux;
 Optim(idd).bin3.params = param;
 Optim(idd).bin3.stats = stats;
 Optim(idd).bin3.depths = dpth;
end
 save('rep_bins.mat','Optim','-v7.3');

end

