%matrix = csvread("PROCESSED_CSV.csv");
pkg load signal
arg_list = argv ();
filename = arg_list{1};
period = str2double(arg_list{2});
matrix = csvread(filename);

[a b] = size(matrix)        %% DEBUG
matrix = matrix(floor(1:0.0025*a),:); %% DEBUG

figure(1)
plot(matrix(:,1), matrix(:,2))

%PARAM: How much time to consider before and after a peak
%       as a mean.
desl_time = 1/2000  %1 milissecond each side

%PARAM: How many times take standard deviation when making
%       the cutting line
dp_range = 1

%PARAM: How many times divide the data
n_div = 50 % number of divisions

desl_points = floor(desl_time/period)
[total_points,c] = size(matrix)
chunk_size = floor(total_points/n_div)

min_v = min(matrix(:,2))
max_v = max(matrix(:,2))
med = max_v*0.9%0.5*(min_v+max_v)

%med = 0.18%mean(matrix(:,2))
end_pos = 0;
pks = []
# List all peaks (does it needs segmentation?)
for i = 1:n_div
  start_pos = end_pos + 1;
  end_pos = min([total_points,(start_pos+chunk_size)]);
  
  if( end_pos-start_pos <= 3)
    break
  endif
  
  x = matrix(start_pos:end_pos,2);
  [v loc] = findpeaks(x);
  [numpeaks c] = size(loc);
  
  %Calculate if v is greater then mean (smaller: not a relevant peak)
  
  [a b] = size(v);
  if( a == 0 )
    continue
  endif

  for j = 1:numpeaks
    if v(j) > med
      pks = [pks; (loc(j)+start_pos)];
    endif   
  endfor
endfor

[totalpeaks,c] = size(pks)
pks_avg = []
for i = 1:totalpeaks
  stt = max([1 (pks(i)-desl_points)]);
  fns = min([total_points, (pks(i)+desl_points)]);
  pks_avg = [pks_avg ; mean(matrix(stt:fns,2))]  ;
endfor

figure(2)
plot(matrix(:,1), matrix(:,2), matrix(pks,1),matrix(pks,2), ".m", matrix(pks,1), pks_avg, "*r"  )

figure(3)
[a b] = size(matrix)

zoom_a = floor(0.0245*a)
zoom_b = floor(0.029*a)

mean_interv = mean_interv = mean(matrix(zoom_a:zoom_b,2));%mean(matrix(zoom_a:zoom_b,2));

mean_peak = pks_avg(1);


plot(matrix(zoom_a:zoom_b,1), matrix(zoom_a:zoom_b,2), matrix(pks(1),1),matrix(pks(1),2), ".m", [matrix(zoom_a,1);matrix(zoom_b,1)], [mean_interv mean_interv], "-k", [matrix(zoom_a,1);matrix(zoom_b,1)], [mean_peak mean_peak], "-g" )


pks_avg
med = mean(matrix(:,2))

pause
pause