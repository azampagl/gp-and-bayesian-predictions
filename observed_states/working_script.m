% kenmore_3_states is a matrix where each row represents one day of observed states. 
% This is the csv we output earlier during pandas processing. The HMM will train on this 
% matrix treating each row as one training sample. First I partitioned the matrix into training and testing
% portions.

train_ind=datasample(1:length(kenmore_3),300,'Replace',false);
kenmore_train_set=kenmore_3(train_ind,:);
kenmore_test_set=removerows(kenmore_3,'ind',train_ind);

% initialize the transition and emission matrices
trans = [0.7,0.25,0.05;
0.25,0.50,0.25;
0.05,0.25,0.7;];
emis= [ 2/3, 1/3, 0;
1/4,1/2,1/4;
0,1/3,2/3];

% use the built in hmmtrain function to train the HMM.
% Sometimes, the function wasn't able to converge within the given number of iterations in which case 
% I re-ran the function passing the transition and emission matrices that the function previous fit.
% It almost always converged quickly after running the function a second time.
[kenmore_est_trans,kenmore_est_emiss]=hmmtrain(kenmore_train_set,kenmore_est_trans,kenmore_est_emiss,'Maxiterations',3000);
% kenmore_sox_binary is a vector that has as many elements as kenmore_3_states has rows. I identified which
% rows in my test correspond to days that had Red Sox games. I will want to see how the HMM performs specifically
% on those days because of the periods of extended traffic following the games. 

kenmore_test_entries=removerows(kenmore_entries,'ind',train_ind);


% test predictive model on 50 points for each row in the test set
[p,n,pc,nc]=pred_and_score( kenmore_test_set,50,kenmore_est_trans,kenmore_est_emiss);

% Generate the full predicted series and naive series for row 22 in the test set
stat=6;
[pred_series naive_series] = predict_series(kenmore_test_set(stat,:),kenmore_est_trans,kenmore_est_emiss);


% This section of code generates the plots of the predicted and actual osberved states on the same plot.
% Included the line of code to plot the naive predictions as well
clf()
stat=6;
[pred_series naive_series] = predict_series(kenmore_test_set(stat,:),kenmore_est_trans,kenmore_est_emiss);

plot(pred_series,'color','r'); hold on;
% change this line to instead plot the naive series
% plot(naive_series,'color','r'); hold on;


plot(kenmore_test_set(stat,:),'color','b')
axis([0,80,0.5,4.5])
title('Plot of Predicted Obs vs Actual Obs')
legend('Predicted Series','Actual Series')


%% Predict numerical value of entries using the predicted observed states

%7 best
stat=7;
test_instance=kenmore_test_set(stat,:);
test_entries= kenmore_test_entries(stat,:);

% do entries prediction
[hmm_ent,naive_ent]=predict_series_ent( test_instance, kenmore_obs_state_means, test_entries, kenmore_est_trans,kenmore_est_emiss);

clf()
plot(test_entries,'color','b'); hold on;

plot(hmm_ent,'color','r'); 
legend('Actual Series','HMM Series')

% change this line to instead plot the naive series
%plot(naive_ent,'color','r');
%legend('Actual Series','Naive Series')

%plot(kenmore_obs_state_means(:,2),'color','r'); 
%legend('Actual Series','Mean Series')

title('Plot of Predicted Obs vs Actual Obs')

hmm_ssr= sum((hmm_ent-test_entries').^2);
naive_ssr= sum((naive_ent-test_entries').^2);
%compare ssr to just predicting mean
mean_ssr=sum((kenmore_obs_state_means(:,2)-test_entries').^2);

%%
hmm_naive_ssr_ratio=zeros(length(kenmore_test_set),1);
hmm_mean_ssr_ratio=zeros(length(kenmore_test_set),1);


for stat=1:length(kenmore_test_set)
    test_instance=kenmore_test_set(stat,:);
    test_entries= kenmore_test_entries(stat,:);

    % do entries prediction
    [hmm_ent,naive_ent]=predict_series_ent( test_instance, kenmore_obs_state_means, test_entries, kenmore_est_trans,kenmore_est_emiss);

    hmm_naive_ssr_ratio(stat)=(sum((hmm_ent-test_entries').^2))/(sum((naive_ent-test_entries').^2));
    hmm_mean_ssr_ratio(stat)=(sum((hmm_ent-test_entries').^2))/(sum((kenmore_obs_state_means(:,2)-test_entries').^2));

end

