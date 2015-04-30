function [ pred ] = predict_next_obs( seq, t, tr,em  )

% Predict observed state at time t using only portion of the sequence
%   1:t-1. Therefore len(seq)>=t. This excludes any influence from observed states
% at times greater than t. This keeps the prediction in the context of the problem
% where we would want to only forecast ahead one time interval using the sequences of 
% previously observed states.
%
% Input:
% seq= observed sequence
% t= index we want predicted. hmmdecode() will be run on seq(1:t-1,:)
%   to acquire posterior probability of each hidden state. Thus,
%   t<=len(seq_)
% tr = matrix of transition probabilities for the HMM from which the 
%    sequence was observed
% em = matrix of emission probabilities for the HMM from which the 
% sequence was observed
% 
% Output:
% pred: integer 1<= pred< n where n is the number of columns in em. 
% n is also the number of observed states

if(t>length(seq))
    t
    length(seq)
    error('t must be less than or equal to the length of the sequence!');
end

post_states= hmmdecode(seq(:,1:t-1),tr,em);

% store posterior likelihood of states at time t-1
post_t=post_states(:,t-1);

%store probabilities of each observation state at time t
probs=[];

% for each obs state
for i=1:length(em(1,:))
    t=0;    
    for j=1:length(tr)    
        t=t+post_t(j)*(tr(j,:)*em(:,i));    
    end
    probs(i)=t;

end
    
pred=probs;

end
