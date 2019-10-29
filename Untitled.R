
X = matrix(c(1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1), nrow = 9)
eps = rnorm(9)
beta = c(1,2,3)
Y = X%*%beta + eps
summary(lm(Y~X))

