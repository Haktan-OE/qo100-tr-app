enum LiveViewStatus { configurationMissing, loading, ready, error }

class LiveViewState {
  const LiveViewState._(this.status, {this.errorMessage});

  const LiveViewState.configurationMissing()
    : this._(LiveViewStatus.configurationMissing);

  const LiveViewState.loading() : this._(LiveViewStatus.loading);

  const LiveViewState.ready() : this._(LiveViewStatus.ready);

  const LiveViewState.error([String? message])
    : this._(LiveViewStatus.error, errorMessage: message);

  final LiveViewStatus status;
  final String? errorMessage;
}
