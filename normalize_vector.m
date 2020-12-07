function [nrm_vec, avg_val, std_val] = normalize_vector (s)
  avg_val = mean(s);
  std_val = std (s);
  nrm_vec = (s - avg_val) / std_val;
end
