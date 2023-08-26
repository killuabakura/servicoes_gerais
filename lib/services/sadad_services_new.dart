import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/payment/payment_webview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';

class SadadServicesNew {
  String sadadId;
  String sadadKey;
  String sadadDomain;
  String remarks;
  num totalAmount;
  late Function(Map<String, dynamic>) onComplete;

  SadadServicesNew({
    required this.sadadId,
    required this.sadadKey,
    required this.sadadDomain,
    required this.totalAmount,
    this.remarks = "",
    required Function(Map<String, dynamic>) onComplete,
  });

  Future<void> payWithSadad(BuildContext context) async {
    Map request = {
      "sadadId": sadadId,
      "secretKey": sadadKey,
      "domain": sadadDomain,
    };
    appStore.setLoading(true);
    await sadadLogin(request).then((accessToken) async {
      await createInvoice(context, accessToken: accessToken)
          .then((value) async {
        //
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> createInvoice(BuildContext context,
      {required String accessToken}) async {
    Map<String, dynamic> req = {
      "countryCode": 974,
      "clientname": appStore.userName.validate(),
      "cellnumber": appStore.userContactNumber.validate().splitAfter('-'),
      "invoicedetails": [
        {
          "description":
              'Name: ${appStore.userFullName} - Email: ${appStore.userEmail}',
          "quantity": 1,
          "amount": totalAmount,
        },
      ],
      "status": 2,
      "remarks": remarks,
      "amount": totalAmount,
    };
    sadadCreateInvoice(request: req, sadadToken: accessToken)
        .then((value) async {
      appStore.setLoading(false);
      log('val:${value[0]['shareUrl']}');

      String? res = await PaymentWebViewScreen(
              url: value[0]['shareUrl'], accessToken: accessToken)
          .launch(context);

      if (res.validate().isNotEmpty) {
        onComplete.call({
          'transaction_id': res,
        });
      } else {
        toast(language.transactionFailed, print: true);
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast('Error: $e', print: true);
    });
  }
}
// Handle CinetPayment
