part of 'paymob_payment.dart';

class PaymobIFrame extends StatefulWidget {
  const PaymobIFrame({
    Key? key,
    this.onPayment,
    required this.redirectURL,
  }) : super(key: key);

  final String redirectURL;
  final void Function(PaymobResponse)? onPayment;

  static Future<PaymobResponse?> show({
    required BuildContext context,
    required String redirectURL,
    void Function(PaymobResponse)? onPayment,
  }) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return PaymobIFrame(
              onPayment: onPayment,
              redirectURL: redirectURL,
            );
          },
        ),
      );

  @override
  State<PaymobIFrame> createState() => _PaymobIFrameState();
}

class _PaymobIFrameState extends State<PaymobIFrame> {
  WebViewController? controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('txn_response_code') &&
                request.url.contains('success') &&
                request.url.contains('id')) {
              final params = Uri.parse(request.url).queryParameters;
              final response = PaymobResponse.fromJson(params);
              if (widget.onPayment != null) {
                widget.onPayment!(response);
              }
              Navigator.pop(context, response);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectURL));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : SafeArea(
              child: WebViewWidget(
                controller: controller!,
              ),
            ),
    );
  }
}
