import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

abstract interface class LiveWebViewFactory {
  Widget create({
    required Uri url,
    required int reloadRequest,
    required VoidCallback onLoading,
    required VoidCallback onReady,
    required ValueChanged<String> onError,
  });
}

class PlatformLiveWebViewFactory implements LiveWebViewFactory {
  const PlatformLiveWebViewFactory();

  @override
  Widget create({
    required Uri url,
    required int reloadRequest,
    required VoidCallback onLoading,
    required VoidCallback onReady,
    required ValueChanged<String> onError,
  }) => _PlatformLiveWebView(
    url: url,
    reloadRequest: reloadRequest,
    onLoading: onLoading,
    onReady: onReady,
    onError: onError,
  );
}

class _PlatformLiveWebView extends StatefulWidget {
  const _PlatformLiveWebView({
    required this.url,
    required this.reloadRequest,
    required this.onLoading,
    required this.onReady,
    required this.onError,
  });

  final Uri url;
  final int reloadRequest;
  final VoidCallback onLoading;
  final VoidCallback onReady;
  final ValueChanged<String> onError;

  @override
  State<_PlatformLiveWebView> createState() => _PlatformLiveWebViewState();
}

class _PlatformLiveWebViewState extends State<_PlatformLiveWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => widget.onLoading(),
          onPageFinished: (_) => widget.onReady(),
          onWebResourceError: (error) {
            if (error.isForMainFrame != false) {
              widget.onError(error.description);
            }
          },
        ),
      )
      ..loadRequest(widget.url);
  }

  @override
  void didUpdateWidget(covariant _PlatformLiveWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _controller.loadRequest(widget.url);
    } else if (widget.reloadRequest != oldWidget.reloadRequest) {
      _controller.reload();
    }
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
