import 'dart:math';

import 'package:booking_system_flutter/main.dart';
import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CinetPayServicesNew {
  String cinetPayApiKey;
  String siteId;
  String secretKey;
  num totalAmount;
  late Function(Map<String, dynamic>) onComplete;

  // Local Variable
  Map<String, dynamic>? response;

  CinetPayServicesNew(
      {required this.cinetPayApiKey,
      required this.totalAmount,
      required Function(Map) onComplete,
      required this.siteId,
      required this.secretKey});

  final String transactionId = Random().nextInt(100000000).toString();

  Future<void> payWithCinetPay({required BuildContext context}) async {
    await Navigator.push(
        getContext, MaterialPageRoute(builder: (_) => cinetPay()));
    appStore.setLoading(false);
  }

  Widget cinetPay() {
    return CinetPayCheckout(
      title: language.lblCheckOutWithCinetPay,
      configData: <String, dynamic>{
        'apikey': cinetPayApiKey,
        'site_id': siteId,
        'notify_url': 'http://mondomaine.com/notify/',
        'mode': 'PRODUCTION',
      },
      paymentData: <String, dynamic>{
        'transaction_id': transactionId,
        'amount': totalAmount,
        'currency': appStore.currencyCode,
        'channels': 'ALL',
        'description': '',
      },
      waitResponse: (data) {
        response = data;
        log(response);

        if (data['status'] == "REFUSED") {
          toast(language.yourPaymentFailedPleaseTryAgain);
        } else if (data['status'] == "ACCEPTED") {
          toast(language.yourPaymentHasBeenMadeSuccessfully);
          appStore.setLoading(false);
          onComplete.call({
            'transaction_id': transactionId,
          });
        }
      },
      onError: (data) {
        response = data;
        log(response);
        appStore.setLoading(false);
      },
    );
  }
}
