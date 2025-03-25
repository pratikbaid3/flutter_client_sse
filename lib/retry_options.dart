class RetryOptions {
  int maxRetryTime;
  int minRetryTime;
  int maxRetry;
  Future Function()? limitReachedCallback;

  RetryOptions({
    this.maxRetryTime = 5000,
    this.minRetryTime = 5000,
    this.maxRetry = 5,
    this.limitReachedCallback,
  });
}
