import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/services/flutter_wave_service_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../main.dart';
import '../../model/configuration_response.dart';
import '../../network/rest_apis.dart';
import '../../services/cinet_pay_services_new.dart';
import '../../services/razorpay_service_new.dart';
import '../../services/sadad_services_new.dart';
import '../../services/stripe_service_new.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';

class UserWalletBalanceScreen extends StatefulWidget {
  const UserWalletBalanceScreen({Key? key}) : super(key: key);

  @override
  State<UserWalletBalanceScreen> createState() => _UserWalletBalanceScreenState();
}

class _UserWalletBalanceScreenState extends State<UserWalletBalanceScreen> {
  TextEditingController walletAmountCont = TextEditingController(text: '0');
  FocusNode walletAmountFocus = FocusNode();

  List<int> defaultAmounts = [150, 200, 500, 1000, 5000, 10000];
  List<PaymentSetting> paymentList = [];
  PaymentSetting? currentPaymentMethod;

  @override
  void initState() {
    super.initState();
    appStore.setUserWalletAmount();

    paymentList = PaymentSetting.decode(getStringAsync(PAYMENT_LIST));
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_COD);

    ///TODO More methods are coming soon
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_CINETPAY);
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_SADAD_PAYMENT);
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_PAYPAL);
  }

  void _handleClick() async {
    if (currentPaymentMethod == null) {
      return toast(language.pleaseChooseAnyOnePayment);
    }

    if (currentPaymentMethod!.type == PAYMENT_METHOD_STRIPE) {
      String key = '';
      String stripeURL = '';
      String stripePaymentPublishKey = '';

      if (currentPaymentMethod!.isTest == 1) {
        key = currentPaymentMethod!.testValue!.stripeKey!;
        stripeURL = currentPaymentMethod!.testValue!.stripeUrl!;
        stripePaymentPublishKey = currentPaymentMethod!.testValue!.stripePublickey!;
      } else {
        key = currentPaymentMethod!.liveValue!.stripeKey!;
        stripeURL = currentPaymentMethod!.liveValue!.stripeUrl!;
        stripePaymentPublishKey = currentPaymentMethod!.liveValue!.stripePublickey!;
      }

      StripeServiceNew stripeServiceNew = StripeServiceNew(
        isTest: currentPaymentMethod!.isTest == 1,
        stripePaymentKey: key,
        stripeURL: stripeURL,
        totalAmount: walletAmountCont.text.toDouble(),
        stripePaymentPublishKey: stripePaymentPublishKey,
        onComplete: (p0) {
          Map req = {"amount": walletAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_STRIPE, "transaction_id": p0['transaction_id']};

          walletTopUp(req);
        },
      );

      stripeServiceNew.stripePay();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_RAZOR) {
      String key = '';
      if (currentPaymentMethod!.isTest == 1) {
        key = currentPaymentMethod!.testValue!.razorKey!;
      } else {
        key = currentPaymentMethod!.liveValue!.razorKey!;
      }

      RazorPayServiceNew razorPayServiceNew = RazorPayServiceNew(
        razorKey: key,
        totalAmount: walletAmountCont.text.toDouble(),
        onComplete: (p0) {
          Map req = {"amount": walletAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_RAZOR, "transaction_id": p0['orderId']};

          walletTopUp(req);
        },
      );
      razorPayServiceNew.razorPayCheckout();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      String flutterWavePublicKey = '';
      String flutterWaveSecretKey = '';

      if (currentPaymentMethod!.isTest == 1) {
        flutterWavePublicKey = currentPaymentMethod!.testValue!.flutterwavePublic!;
        flutterWaveSecretKey = currentPaymentMethod!.testValue!.flutterwaveSecret!;
      } else {
        flutterWavePublicKey = currentPaymentMethod!.liveValue!.flutterwavePublic!;
        flutterWaveSecretKey = currentPaymentMethod!.liveValue!.flutterwaveSecret!;
      }

      FlutterWaveServiceNew flutterWaveServiceNew = FlutterWaveServiceNew();

      flutterWaveServiceNew.checkout(
        totalAmount: walletAmountCont.text.toDouble(),
        flutterWavePublicKey: flutterWavePublicKey,
        flutterWaveSecretKey: flutterWaveSecretKey,
        isTestMode: currentPaymentMethod!.isTest == 1,
        onComplete: (p0) {
          Map req = {"amount": walletAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_FLUTTER_WAVE, "transaction_id": p0['transaction_id']};

          walletTopUp(req);
        },
      );
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_CINETPAY) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appStore.currencyCode)) {
        toast(language.cinetPayNotSupportedMessage);
        return;
      }
      String cinetPayApiKey = '';
      String siteId = '';
      String secretKey = '';

      if (currentPaymentMethod!.isTest == 1) {
        cinetPayApiKey = currentPaymentMethod!.testValue!.cinetPublicKey!;
        siteId = currentPaymentMethod!.testValue!.cinetId!;
        secretKey = currentPaymentMethod!.testValue!.cinetKey!;
      } else {
        cinetPayApiKey = currentPaymentMethod!.liveValue!.cinetPublicKey!;
        siteId = currentPaymentMethod!.liveValue!.cinetId!;
        secretKey = currentPaymentMethod!.liveValue!.cinetKey!;
      }

      CinetPayServicesNew cinetPayServices = CinetPayServicesNew(
        cinetPayApiKey: cinetPayApiKey,
        totalAmount: walletAmountCont.text.toDouble(),
        siteId: siteId,
        secretKey: secretKey,
        onComplete: (p0) {
          Map req = {
            "amount": walletAmountCont.text.toDouble(),
            "transaction_type": PAYMENT_METHOD_CINETPAY,
            "transaction_id": p0['transaction_id']
          };

          walletTopUp(req);
        },
      );

      cinetPayServices.payWithCinetPay(context: context);
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_SADAD_PAYMENT) {
      String sadadId = '';
      String sadadKey = '';
      String sadadDomain = '';
      if (currentPaymentMethod!.isTest == 1) {
        sadadId = currentPaymentMethod!.testValue!.sadadId!;
        sadadKey = currentPaymentMethod!.testValue!.sadadKey!;
        sadadDomain = currentPaymentMethod!.testValue!.sadadDomain!;
      } else {
        sadadId = currentPaymentMethod!.liveValue!.sadadId!;
        sadadKey = currentPaymentMethod!.liveValue!.sadadKey!;
        sadadDomain = currentPaymentMethod!.liveValue!.sadadDomain!;
      }

      SadadServicesNew sadadServices = SadadServicesNew(
        sadadId: sadadId,
        sadadKey: sadadKey,
        sadadDomain: sadadDomain,
        totalAmount: walletAmountCont.text.toDouble(),
        remarks: "Wallet Top Up",
        onComplete: (p0) {
          Map req = {
            "amount": walletAmountCont.text.toDouble(),
            "transaction_type": PAYMENT_METHOD_SADAD_PAYMENT,
            "transaction_id": p0['transaction_id']
          };

          walletTopUp(req);
        },
      );

      sadadServices.payWithSadad(context);
    }
  }

  String getPaymentMethodIcon(String value) {
    if (value == PAYMENT_METHOD_STRIPE) {
      return stripe_logo;
    } else if (value == PAYMENT_METHOD_RAZOR) {
      return razorpay_logo;
    } else if (value == PAYMENT_METHOD_CINETPAY) {
      return cinetpay_logo;
    } else if (value == PAYMENT_METHOD_FLUTTER_WAVE) {
      return flutter_wave_logo;
    } else if (value == PAYMENT_METHOD_SADAD_PAYMENT) {
      return "";
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.myWallet,
      child: AnimatedScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.width(),
                padding: EdgeInsets.all(16),
                color: context.cardColor,
                child: Row(
                  children: [
                    Text(language.balance, style: boldTextStyle(color: context.primaryColor)).expand(),
                    Observer(builder: (context) => PriceWidget(price: appStore.userWalletAmount, size: 16, isBoldText: true)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(language.topUpWallet, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                  8.height,
                  Text(language.topUpAmountQuestion, style: secondaryTextStyle()),
                  Container(
                    width: context.width(),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationDefault(
                      color: walletCardColor,
                      borderRadius: radius(8),
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          textAlign: TextAlign.center,
                          controller: walletAmountCont,
                          focus: walletAmountFocus,
                          textStyle: primaryTextStyle(size: 20, color: Colors.white),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onTap: () {
                            if (walletAmountCont.text == '0') {
                              walletAmountCont.selection = TextSelection(baseOffset: 0, extentOffset: walletAmountCont.text.length);
                            }
                          },
                          decoration: InputDecoration(
                            prefixText: '${isCurrencyPositionLeft ? appStore.currencySymbol : ''}${isCurrencyPositionRight ? appStore.currencySymbol : ''}',
                            prefixStyle: primaryTextStyle(color: Colors.white),
                          ),
                          onChanged: (p0) {
                            //
                          },
                        ),
                        24.height,
                        Wrap(
                          spacing: 30,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: List.generate(defaultAmounts.length, (index) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: boxDecorationDefault(
                                color: defaultAmounts[index].toString() == walletAmountCont.text ? context.cardColor : Colors.white12,
                                borderRadius: radius(8),
                              ),
                              child: Text(
                                defaultAmounts[index].toString().formatNumberWithComma(),
                                style: primaryTextStyle(color: defaultAmounts[index].toString() == walletAmountCont.text ? context.primaryColor : Colors.white),
                              ),
                            ).onTap(() {
                              walletAmountCont.text = defaultAmounts[index].toString();
                              setState(() {});
                            });
                          }),
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Text(language.paymentMethod, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                  4.height,
                  Text(language.selectYourPaymentMethodToAddBalance, style: secondaryTextStyle()),
                  if (paymentList.isNotEmpty) 16.height,
                  if (paymentList.isNotEmpty)
                    AnimatedWrap(
                      itemCount: paymentList.length,
                      listAnimationType: ListAnimationType.FadeIn,
                      fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                      spacing: 8,
                      runSpacing: 18,
                      itemBuilder: (context, index) {
                        PaymentSetting value = paymentList[index];

                        if (value.status.validate() == 0) return Offstage();
                        String icon = getPaymentMethodIcon(value.type.validate());

                        return Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              child: Container(
                                width: context.width() * 0.249,
                                height: 60,
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                decoration: boxDecorationDefault(
                                  borderRadius: radius(8),
                                  border: Border.all(color: primaryColor),
                                ),
                                //decoration: BoxDecoration(border: Border.all(color: primaryColor)),
                                alignment: Alignment.center,
                                child: icon.isNotEmpty ? Image.asset(icon) : Text(value.type.validate(), style: primaryTextStyle()),
                              ).onTap(() {
                                currentPaymentMethod = value;

                                setState(() {});
                              }),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: currentPaymentMethod == value ? EdgeInsets.all(2) : EdgeInsets.zero,
                                decoration: boxDecorationDefault(color: context.primaryColor),
                                child: currentPaymentMethod == value ? Icon(Icons.done, size: 16, color: Colors.white) : Offstage(),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    NoDataWidget(
                      title: language.lblNoPayments,
                      imageWidget: EmptyStateWidget(),
                    ),
                  30.height,
                  AppButton(
                    width: context.width(),
                    height: 16,
                    color: context.primaryColor,
                    text: language.proceedToTopUp,
                    textStyle: boldTextStyle(color: white),
                    onTap: () {
                      _handleClick();
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
            ],
          ),
        ],
      ),
    );
  }
}
