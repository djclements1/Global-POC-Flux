function target = get_data(varargin)

  A.var = 'biov_tot';
  A.shape = nan;
  A = parse_pv_pairs(A,varargin);

  % Location of stored data
  
  %  outpath='YourDataLocation';
  outpath  = pwd;
  load([outpath,'/POC_UVP5_onWOAgrid.mat'])

  if min(poc.lon) < 25
      tmp = find(poc.lon<25);
      for ind = 1:12;
         poc.(A.var)(:,:,:,ind) =  [poc.(A.var)(max(tmp)+1:end,...
                               :,:,ind); poc.(A.var)(1:max(tmp),:,:,ind)];
      end
   end


  target = poc.(A.var);
  if isnan(A.shape)
  target = target(:);
  end
 
