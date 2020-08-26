function y = cv2(ts)
% each spike get corresponding cv2 value 
% (by the preceeding ISI and the following ISI) 
% [e.g.]  ss_cv = cv2(data.neuron.unit01.spiketimes);

isi=diff(ts);
cv_2=2*abs(isi(2:end)-isi(1:end-1))./(isi(2:end)+isi(1:end-1));

y.ts=ts(:);
y.cv2=[NaN;cv_2(:);NaN];
y.cv2_avg=nanmean(cv_2);




