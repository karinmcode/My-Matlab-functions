function y=myceilfix(x)
% round away from 0

y =ceil(abs(x)).*sign(x);
