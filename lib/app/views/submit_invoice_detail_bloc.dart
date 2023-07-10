import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pay4freight/common/completed_dialog.dart';
import 'package:pay4freight/network_helper/constant.dart';
import 'package:pay4freight/network_helper/prefrences.dart';
import 'package:pay4freight/screens/home/credit_check/model/credit_exception_model.dart';
import 'package:pay4freight/screens/home_screen.dart';
import 'package:pay4freight/screens/signing/model/login_resp.dart';
import 'package:pay4freight/screens/submit_invoice/model/invoice_model.dart';
import 'package:pay4freight/screens/submit_invoice/model/merge_pdf_response.dart';
import 'package:pay4freight/screens/webview/model/post_add_pdf.dart';
import 'package:pay4freight/utils/file_util.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../database/database_helper.dart';
import '../../../locale/AppLocalizations.dart';
import '../../../network_helper/api_repository.dart';
import '../../../network_helper/post_by_http.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/pdf_generator/pdf_utils.dart';
import '../../../utils/utils.dart';
import '../../signing/login_screen.dart';
import '../../webview/model/post_add_pdf.dart';
import '../model/submit_invoice_detail_model.dart';

class SubmitInvoiceDetailBloc {
  final List<SubmitInvoiceDetailModel> _imageList = [];
  List<String>? pdfFilesPathList = [];

  List<String> invoiceAllPdfsList = [];
  List<String> bolAllPdfsList = [];
  List<String> rateConfAllPdfsList = [];
  List<String> lumperRecAllPdfsList = [];
  List<String> otherAllPdfsList = [];
  List<String> totalAllPdfsList = [];
  List<String> multiplePdfList = [];

  ///

  ///............................................
  var load_num, amount_num;
  var cutomer_name;
  var fileID_PDF;
  var file_pdf_name;
  var pdf_file_dir;
  //

  //.....................................................................
  // var fileSizeFull = 500000000;
  var fileSizeFull = 17000000;
  var imgPdfFileSizeFull = 16000000;

  double totalFileSize = 0.0;
  final StreamController<List<SubmitInvoiceDetailModel>> _imageController =
      StreamController<List<SubmitInvoiceDetailModel>>();

  StreamSink<List<SubmitInvoiceDetailModel>> get imageSink =>
      _imageController.sink;

  Stream<List<SubmitInvoiceDetailModel>> get imageStream =>
      _imageController.stream;

  final StreamController<bool> _progressController = StreamController<bool>();

  StreamSink<bool> get progressSink => _progressController.sink;

  Stream<bool> get progressStream => _progressController.stream;

  final StreamController<bool> _progressCountController =
      StreamController<bool>();

  StreamSink<bool> get progressCountSink => _progressCountController.sink;

  Stream<bool> get progressCountStream => _progressCountController.stream;
  String emailTo = "";

  //var list = [NetworkConstants.submit_invoice_email];
  List<String> list = [];

  //  bool canSend = await FlutterMailer.canSendMail();
  final _repository = ApiRepository();
  bool isSent = false;
  bool chekReq4Email = false;
/*  Future<CheckUser> checkUserAuthorized(
      {String? userId, BuildContext? context}) async {
    try {
      CheckUser checkUser =
          await _repository.checkUserApiRepository(userId: userId);
      debugPrint('CheckUser:- ${checkUser.message}');
      if (checkUser.message == "Unauthorized") {
        SessionManager _sessionManager = new SessionManager();
        _sessionManager.setIsLogin(false);
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            _sessionManager.clearAllData();
            Navigator.pushNamedAndRemoveUntil(
                context, AppString.LOGIN_SCREEN_ROUTE, (route) => false);
          },
        );
      }
    } catch (e) {
      return CheckUser();
    }
  }*/
  void checkUser({required String userid, required BuildContext context}) {
    _repository.checkUserAuthentication(userId: userid).then((onResponse) {
      if (onResponse.message == "Unauthorized") {
        progressSink.add(false);
        AppPreference().clearSharedPreferences().whenComplete(
              () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: LoginScreen.name),
                    builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              ),
            );
      } else {
        progressSink.add(false);
      }
      return null;
    }).catchError((onError) {
      progressSink.add(false);

      Utils.showToast(onError.toString());
    });
  }

  // Email email
  void checkIfLoadNumberValueIsExist(
      String loadNumber, BuildContext context) async {
    try {
      var loadNumberInt = loadNumber;
      List<Map<String, dynamic>> _list =
          await DataBaseHelper.instance.queryItem(loadNumberInt);
      debugPrint('database_testing :- $_list');
      if (_list.isEmpty) {
        await DataBaseHelper.instance
            .insert(_gettingInsertedValue(loadNumberInt));
        listInit(_gettingInsertedValue(loadNumberInt), context);
      } else {
        listInit(_list[0], context);
      }
    } catch (e) {
      debugPrint("database_testing:-  error ${e.toString()}");
      listInit(_gettingInsertedValue(loadNumber), context);
    }
  }

  Map<String, dynamic> _gettingInsertedValue(var loadNumber) {
    Map<String, dynamic> _loadNumberValue = <String, dynamic>{};
    _loadNumberValue = {
      DataBaseHelper.loadNumber: loadNumber,
      DataBaseHelper.invoiceCount: 0,
      DataBaseHelper.invoicePath: "null",
      DataBaseHelper.invoicePdfPath: "null",
      DataBaseHelper.invoicePdfPathSize: "null",
      DataBaseHelper.bolCount: 0,
      DataBaseHelper.bolPath: "null",
      DataBaseHelper.bolPdfPath: "null",
      DataBaseHelper.bolPdfPathSize: "null",
      DataBaseHelper.rateConfirmationCount: 0,
      DataBaseHelper.rateConfirmationPath: "null",
      DataBaseHelper.rateConfirmationPdfPath: "null",
      DataBaseHelper.rateConfirmationPdfPathSize: "null",
      DataBaseHelper.lumperReceiptCount: 0,
      DataBaseHelper.lumperReceiptPath: "null",
      DataBaseHelper.lumperReceiptPdfPath: "null",
      DataBaseHelper.lumperReceiptPdfPathSize: "null",
      DataBaseHelper.otherCount: 0,
      DataBaseHelper.otherPath: "null",
      DataBaseHelper.otherPdfPath: "null",
      DataBaseHelper.otherPdfPathSize: "null",
      DataBaseHelper.isEmailSent: 0,
    };
    return _loadNumberValue;
  }

  void listInit(Map<String, dynamic> _item, BuildContext context) {
    _imageList.clear();
    pdfFilesPathList!.clear();
    SubmitInvoiceDetailModel _submitInvoiceDetailModelOne =
        SubmitInvoiceDetailModel(
      display_title:
          AppLocalizations.of(context)!.translate('invoice').toString(),
      //display_title: AppString.invoice,
      title: AppString.invoice,
      icon: AppImages.icon_submit_invoice,
      count: _item[DataBaseHelper.invoiceCount],
      loadNumber: _item[DataBaseHelper.loadNumber].toString(),
      imagePath: _item[DataBaseHelper.invoicePath],
      pdfFilesPath: _item[DataBaseHelper.invoicePdfPath],
      pdfFilesPathSize: _item[DataBaseHelper.invoicePdfPathSize],
    );
    SubmitInvoiceDetailModel _submitInvoiceDetailModelTwo =
        SubmitInvoiceDetailModel(
      display_title: AppLocalizations.of(context)!.translate('bol').toString(),
      //display_title: AppString.bol,
      title: AppString.bol,
      icon: AppImages.icon_bol,
      count: _item[DataBaseHelper.bolCount],
      loadNumber: _item[DataBaseHelper.loadNumber].toString(),
      imagePath: _item[DataBaseHelper.bolPath],
      pdfFilesPath: _item[DataBaseHelper.bolPdfPath],
      pdfFilesPathSize: _item[DataBaseHelper.bolPdfPathSize],
    );
    SubmitInvoiceDetailModel _submitInvoiceDetailModelThree =
        SubmitInvoiceDetailModel(
      display_title: AppLocalizations.of(context)!
          .translate('rate_confirmation')
          .toString(),
      //display_title: AppString.rate_confirmation,
      title: AppString.rate_confirmation,
      icon: AppImages.icon_rate_confirmation,
      count: _item[DataBaseHelper.rateConfirmationCount],
      loadNumber: _item[DataBaseHelper.loadNumber].toString(),
      imagePath: _item[DataBaseHelper.rateConfirmationPath],
      pdfFilesPath: _item[DataBaseHelper.rateConfirmationPdfPath],
      pdfFilesPathSize: _item[DataBaseHelper.rateConfirmationPdfPathSize],
    );
    SubmitInvoiceDetailModel _submitInvoiceDetailModelFour =
        SubmitInvoiceDetailModel(
      display_title:
          AppLocalizations.of(context)!.translate('lumper_receipt').toString(),
      // display_title: AppString.lumper_receipt,
      title: AppString.lumper_receipt,
      icon: AppImages.icon_lumper_reciept,
      count: _item[DataBaseHelper.lumperReceiptCount],
      loadNumber: _item[DataBaseHelper.loadNumber].toString(),
      imagePath: _item[DataBaseHelper.lumperReceiptPath],
      pdfFilesPath: _item[DataBaseHelper.lumperReceiptPdfPath],
      pdfFilesPathSize: _item[DataBaseHelper.lumperReceiptPdfPathSize],
    );
    SubmitInvoiceDetailModel _submitInvoiceDetailModelFive =
        SubmitInvoiceDetailModel(
      display_title:
          AppLocalizations.of(context)!.translate('others').toString(),

      //display_title: AppString.others,
      title: AppString.others,
      icon: AppImages.icon_others,
      count: _item[DataBaseHelper.otherCount],
      loadNumber: _item[DataBaseHelper.loadNumber].toString(),
      imagePath: _item[DataBaseHelper.otherPath],
      pdfFilesPath: _item[DataBaseHelper.otherPdfPath],
      pdfFilesPathSize: _item[DataBaseHelper.otherPdfPathSize],
    );

    _imageList.add(_submitInvoiceDetailModelOne);
    _imageList.add(_submitInvoiceDetailModelTwo);
    _imageList.add(_submitInvoiceDetailModelThree);
    _imageList.add(_submitInvoiceDetailModelFour);
    _imageList.add(_submitInvoiceDetailModelFive);

    imageSink.add(_imageList);
  }

  List<SubmitInvoiceDetailModel> get submitInvoiceModelList => _imageList;

  void getProfile(
      {required String userid,
      required BuildContext context,
      required Invoice invoice}) {
    log("Get Profile invoice");
    log("userid log -- $userid,,, invoice  --$invoice");
    load_num = invoice.loadNo;
    amount_num = invoice.amount;
    cutomer_name = invoice.customerName;
    log("load number Globle" + invoice.loadNo.toString());

    _repository.getProfile(userId: userid).then((onResponse) async {
      log("status code---- 1" + onResponse.status.toString());
      if (onResponse.status == true) {
        log("status code---- 2" + onResponse.status.toString());
        AppPreference().settingPrefs(onResponse);
        if (Utils.isValidString(onResponse.data!.toEmail)) {
          var data = onResponse.data!.toEmail.toString().split(",");
          list.addAll(data);
          print('MyAllEmails  ${list.length}  ');
        }

        await deleteLoadNumber(
            context,
            Invoice(
              loadNo: invoice.loadNo,
              customerName: invoice.customerName,
              amount: invoice.amount,
              isFuelAdvance: invoice.isFuelAdvance,
              comment: invoice.comment,
              fundingType: invoice.fundingType,
              companyEmail: onResponse.data?.email ?? '',
              username:
                  '${onResponse.data?.nome ?? ''} ${onResponse.data?.cognome ?? ''}',
              companyName: onResponse.data?.company ?? '',
            ));
      }
      return null;
    }).catchError((onError) async {
      progressSink.add(false);
      Utils.showToast(onError.toString());
      await Sentry.captureException(onError,
          hint: 'SubmitInvoiceDetailBloc getProfile catchError');
    });
  }

  Future<void> deleteLoadNumber(
    BuildContext context,
    Invoice invoice,
  ) async {
    progressSink.add(true);
    print("MyLoadNumber ${invoice.loadNo}");
    File? pdfFile;
    log("Sheet");
    String pdfFileName =
        'Transmittal Sheet-${invoice.companyName}_${AppString.fundingType}-${invoice.fundingType}.pdf';
    pdfFile =
        await PdfUtils.generatePdf(invoice: invoice, fileName: pdfFileName);
    log("files");
    pdf_file_dir = pdfFile.path;

    log(pdfFilesPathList.toString());
    log(pdfFile.toString() + "padFile");

    try {
      if (!_checkIfDataIsExist()) {
        Utils.showErrorSnackBar(
            message: AppLocalizations.of(context)!
                .translate('select_photo')
                .toString(),
            context: context);
        progressSink.add(false);
        return;
      }

      await _getAllImageAtOnePlace();
      await _getAllPdfAtOnePlace();

      // new code

      multiplePdfList.addAll(invoiceAllPdfsList);
      multiplePdfList.addAll(bolAllPdfsList);
      multiplePdfList.addAll(rateConfAllPdfsList);
      multiplePdfList.addAll(lumperRecAllPdfsList);
      multiplePdfList.addAll(otherAllPdfsList);
      log("multiplePdfList ${multiplePdfList.length}");

      totalAllPdfsList =
          (await _getPdfPathMergedFile(invoice.loadNo, multiplePdfList))!;
      print("totalAllPdfsList ${totalAllPdfsList.length}");
      print("multiplePdfList ${multiplePdfList.toString()}");
      await savePDFdata1(
          context: context,
          reqModel: PostReqModelPDFsub(
            amount: amount_num.toString(),
            loadNumber: load_num.toString(),
            mcNumber: cutomer_name.toString(),
            invoiceMergePdf: file_pdf_name.toString(),
            fileId: fileID_PDF.toString(),
          ));

      // sendEmail(context, invoice, totalAllPdfsList, "", false);
      // await showInvoiceUploadDialog(context, invoice, totalAllPdfsList);
      if (totalAllPdfsList.isNotEmpty) {
        log("sending 370");

        if (chekReq4Email == true) {
          sendInvoiceEmailStop(
              context, invoice, totalAllPdfsList, multiplePdfList);
          log("sending 370 true");
        } else {
          log("sending 370 false");

          await sendInvoiceEmail(
              context, invoice, totalAllPdfsList, multiplePdfList);
        }
      } else {
        print("deleteLoadNumber totalAllPdfsList is Empty");
        await Sentry.captureMessage(
            'deleteLoadNumber totalAllPdfsList is Empty');
        Utils.showErrorSnackBar(
            message: AppLocalizations.of(context)!
                .translate('something_went_wrong')
                .toString(),
            context: context);
        progressSink.add(false);
      }
      _clearAllPdfLists();
    } catch (error, stackTrace) {
      print("deleteLoadNumber catch $error");
      Utils.showErrorSnackBar(
          message: AppLocalizations.of(context)!
              .translate('something_went_wrong')
              .toString(),
          context: context);
      print("something_went_wrong ${error.toString()}");
      _clearAllPdfLists();
      progressSink.add(false);
      await Sentry.captureException(error,
          stackTrace: stackTrace, hint: 'deleteLoadNumber catch');
    }
  }

  _clearAllPdfLists() {
    invoiceAllPdfsList.clear();
    bolAllPdfsList.clear();
    rateConfAllPdfsList.clear();
    lumperRecAllPdfsList.clear();
    otherAllPdfsList.clear();
  }

// mergeMultiplePDF call from here
  Future mergeMultiplePDF(outputDirPath, List<String> pdfFileList) async {
    log(pdfFileList.toString() + "File to leagth");
    pdfFileList.add(pdf_file_dir);
    try {
      debugPrint(
          "SUBMIT INVOICE DETAIL BLOC : mergeMultiplePDF pdfFileListLength ${pdfFileList.length}  outputDirPath $outputDirPath ");

      MergePdfResponse response = await _repository.mergeMultiplePDF(
        loadnum: load_num,
        paths: pdfFileList,
        outputDirPath: outputDirPath,
      );
      log(response.toString() + "mm11");
      if (response.status == true &&
          response.data != null &&
          Utils.isValidString(response.data?.finalPDF)) {
        log(response.toString() + "mm22");
        final bytes = base64Decode(response.data!.finalPDF!);
        File file = File(outputDirPath);
        file.writeAsBytesSync(bytes);
//
        log("log for PDF");
        log("merage response DATA" + response.data!.fileId.toString());
        log("merage response DATA  file Id" +
            response.data!.fileId!.id.toString());

        fileID_PDF = response.data!.fileId!.id;
        file_pdf_name = response.data!.invoiceMergePdf;
        log("merage response DATA  ID" + response.data!.fileId!.id.toString());
        log("merage response DATA  invoice" +
            response.data!.invoiceMergePdf!.toString());

        return true;
      }
    } catch (e, stackTrace) {
      log('SUBMIT INVOICE DETAIL BLOC : mergeMultiplePDF : ERROR : $e');
      log('SUBMIT INVOICE DETAIL BLOC : mergeMultiplePDF : STACK TRACE : $stackTrace');
      await Sentry.captureException(e,
          stackTrace: stackTrace, hint: 'mergeMultiplePDF catch');
    }
    return false;
  }

  Future savePDFdata1(
      {required PostReqModelPDFsub reqModel,
      required BuildContext context}) async {
    // progressSink.add(true);

    await _repository.savepdfFILE(savePDF: reqModel).then((onResponse) {
      log(onResponse.status.toString() + "success-----");
      if (onResponse.status == true) {
        log(onResponse.status.toString());
        log("true for mail");
        chekReq4Email = true;
      } else {
        log("false for mail");
        chekReq4Email = false;
        // progressSink.add(false);
        // Utils.showErrorSnackBar(
        //     message: onResponse.message ?? '', context: context);
      }
      return null;
    }).catchError((onError) {
      progressSink.add(false);
      Utils.showToast(onError.toString());
    });
  }

  // savePDFdata() async {
  //   log('sumbitDAtA__PDF');

  //   log(load_num.toString());
  //   // log(" Customer name $cutomer_name");
  //   // log(" ID $fileID_PDF");
  //   // log(" name $file_pdf_name");
  //   _repository
  //       .savepdfFILE(
  //           savePDF: PostReqModelPDFsub(
  //     loadNumber: load_num,
  //     mcNumber: cutomer_name,
  //     fileId: fileID_PDF,
  //     invoiceMergePdf: file_pdf_name,
  //   ))
  //       .then((onResponse) async {
  //     log("status code---- 1" + onResponse.toString());
  //     if (onResponse.status == true) {
  //       log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" +
  //           onResponse.toString());

  //       // if (Utils.isValidString(onResponse.data!.toEmail)) {
  //       //   var data = onResponse.data!.toEmail.toString().split(",");
  //       //   list.addAll(data);
  //       //   print('MyAllEmails  ${list.length}  ');
  //       // }
  //     }
  //     log("null");
  //     return null;
  //   }).catchError((onError) async {
  //     progressSink.add(false);
  //     Utils.showToast(onError.toString());
  //     await Sentry.captureException(onError,
  //         hint: 'SubmitInvoiceDetailBloc getProfile catchError');
  //   });
  // }

  Future<void> sendInvoiceEmail(BuildContext context, Invoice invoice,
      List<String> pdfPath, List<String> allPdfs) async {
    log("sendInvoiceEmail *** ${invoice.loadNo} isSent $isSent  pdfPath length ${pdfPath.length}");
    String platformResponse = "";
    try {
      // var detroit = tz.getLocation('America/Chicago');
      // var now = tz.TZDateTime.now(detroit);
      // String dateTime = DateFormat("MM-dd-yyyy=hh:mm a").format(now);
      // debugPrint("sendInvoiceEmail CSTTimeNow $dateTime  ");

      String content = getEmailBody(invoice);
      From from =
          From(email: Constant.sendgrid_from_email, name: "Do Not Reply");
      From replyTo = From(
          email: AppPreference().userEmail, name: AppPreference().userName);
      List<Content> contentList = [];

      contentList.add(Content(type: "text/html", value: content));
      List<To> toList = [];
      toList.add(To(email: Constant.submit_invoice_to_email));
      List<To> ccList = [];

      for (var element in list) {
        if (Utils.isValidString(element)) {
          ccList.add(To(email: element));
        }
      }

      for (int i = 0; i < pdfPath.length; i++) {
        log("sending email");
        if (!isSent) {
          await Future.delayed(const Duration(seconds: 2));
          debugPrint("sendInvoiceEmail inside For *** $i ${[
            pdfPath[i]
          ]}  isSent  $isSent");
          String subject = await getEmailSubject(invoice, i + 1);
          // Platform messages may fail, so we use a try/catch PlatformException.

          List<Personalizations> personalization = [];

          personalization.add(Personalizations(
              to: toList,
              cc: ccList.isNotEmpty ? ccList : null,
              subject: subject));

          List<Attachment> attachments = [];

          ///Transmittal sheet generation part, Need to uncomment when required - Don't Delete this code.

          File? pdfFile;
          if (i == 0) {
            // String pdfFileName =
            //     'Transmittal Sheet-${invoice.companyName}_${AppString.fundingType}-${invoice.fundingType}.pdf';
            // pdfFile = await PdfUtils.generatePdf(
            //     invoice: invoice, fileName: pdfFileName);
            // final bytes = pdfFile.readAsBytesSync();
            // String pdfBase64 = base64Encode(bytes);
            // attachments
            //     .add(Attachment(content: pdfBase64, filename: pdfFileName));
          }

          final bytes = File(pdfPath[i]).readAsBytesSync();
          String pdfBase64 = base64Encode(bytes);

          attachments.add(Attachment(
              content: pdfBase64, filename: path.basename(pdfPath[i])));

          CreditExceptionModel creditExceptionModel = CreditExceptionModel(
              replyTo: replyTo,
              from: from,
              content: contentList,
              personalizations: personalization,
              attachments: attachments);
          // debugPrint(
          //     "sendInvoiceEmail creditExceptionModel param  ${creditExceptionModel.toJson()}");
          isSent = true;
          print("isSent try ********$isSent");
          var response = await _repository.sendCreditExceptionApiRepository(
              creditExceptionModel, context, false);
          log('Submit Invoice Detail Bloc : sendInvoiceEmail : Response : $response');
          if (response?.statusCode == 202) {
            platformResponse = AppLocalizations.of(context)!
                .translate('email_sent_successfully')
                .toString();
            await _removeFileFromCache(context, invoice.loadNo, pdfPath[i]);
            if (i == (pdfPath.length - 1)) {
              log("im am run");

              progressSink.add(false);
              AppString.commnetsaved = '';
              list.clear();
              // debugPrint(
              //     "sendInvoiceEmail : All Pdf List : ${allPdfs.toString()}");
              await _removeAllFileFromCache(context, invoice.loadNo, allPdfs);
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext dCtx) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: CompletedDialog(
                        title: AppLocalizations.of(context)!
                            .translate('completed')
                            .toString(),
                        subtitle: AppLocalizations.of(context)!
                            .translate('submit_invoice_email_sent_success_msg')
                            .toString(),
                        onPressed: () {
                          log("find log");

                          // savePDFdata1(
                          //     context: context,
                          //     reqModel: PostReqModelPDFsub(
                          //       amount: amount_num.toString(),
                          //       loadNumber: load_num.toString(),
                          //       mcNumber: cutomer_name.toString(),
                          //       invoiceMergePdf: file_pdf_name.toString(),
                          //       fileId: fileID_PDF.toString(),
                          //     ));
                          log(load_num.toString());
                          Navigator.of(dCtx).pop();
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () async {
                              // submitData(context);
                              // savePDFdata();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: HomeScreen.name),
                                      builder: (context) => const HomeScreen()),
                                  (Route<dynamic> route) => false);
                            },
                          );
                        },
                      ),
                    );
                  });
            } else {
              Utils.showErrorSnackBar(
                  message: platformResponse +
                      ".${AppLocalizations.of(context)!.translate('please_wait').toString()}",
                  context: context);
            }
          } else {
            progressSink.add(false);
            clearCommentAndEmail(pdfPath.length);
            platformResponse = AppLocalizations.of(context)!
                .translate('something_went_wrong')
                .toString();
            Utils.showErrorSnackBar(
                message: platformResponse, context: context);
            await Future.delayed(const Duration(seconds: 2));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: HomeScreen.name),
                    builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false);
          }
          isSent = false;
          log("isSent Last ********$isSent");
        }
      }
    } catch (error, stackTrace) {
      progressSink.add(false);
      debugPrint('sendInvoiceEmail Catch Error : $error');
      await Sentry.captureException(error,
          stackTrace: stackTrace, hint: 'sendInvoiceEmail final catch');
    }
  }

  Future<void> sendInvoiceEmailStop(BuildContext context, Invoice invoice,
      List<String> pdfPath, List<String> allPdfs) async {
    log("sendInvoiceEmail *** ${invoice.loadNo} isSent $isSent  pdfPath length ${pdfPath.length}");
    String platformResponse = "";
    try {
      // var detroit = tz.getLocation('America/Chicago');
      // var now = tz.TZDateTime.now(detroit);
      // String dateTime = DateFormat("MM-dd-yyyy=hh:mm a").format(now);
      // debugPrint("sendInvoiceEmail CSTTimeNow $dateTime  ");

      // String content = getEmailBody(invoice);
      From from =
          From(email: Constant.sendgrid_from_email, name: "Do Not Reply");
      From replyTo = From(
          email: AppPreference().userEmail, name: AppPreference().userName);
      List<Content> contentList = [];

      // contentList.add(Content(type: "text/html", value: content));
      // List<To> toList = [];
      // toList.add(To(email: Constant.submit_invoice_to_email));
      // List<To> ccList = [];

      // for (var element in list) {
      //   if (Utils.isValidString(element)) {
      //     ccList.add(To(email: element));
      //   }
      // }

      for (int i = 0; i < pdfPath.length; i++) {
        log("sending email");
        if (!isSent) {
          await Future.delayed(const Duration(seconds: 2));
          debugPrint("sendInvoiceEmail inside For *** $i ${[
            pdfPath[i]
          ]}  isSent  $isSent");
          // String subject = await getEmailSubject(invoice, i + 1);
          // Platform messages may fail, so we use a try/catch PlatformException.

          // List<Personalizations> personalization = [];

          // personalization.add(Personalizations(
          //     to: toList,
          //     cc: ccList.isNotEmpty ? ccList : null,
          //     subject: subject));

          // List<Attachment> attachments = [];

          // debugPrint(
          //     "sendInvoiceEmail creditExceptionModel param  ${creditExceptionModel.toJson()}");
          isSent = true;
          print("isSent try ********$isSent");

          if (2 > 1) {
            platformResponse = AppLocalizations.of(context)!
                .translate('email_sent_successfully')
                .toString();
            await _removeFileFromCache(context, invoice.loadNo, pdfPath[i]);
            if (i == (pdfPath.length - 1)) {
              log("im am run for not");

              progressSink.add(false);
              AppString.commnetsaved = '';
              list.clear();
              // debugPrint(
              //     "sendInvoiceEmail : All Pdf List : ${allPdfs.toString()}");
              await _removeAllFileFromCache(context, invoice.loadNo, allPdfs);
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext dCtx) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: CompletedDialog(
                        title: AppLocalizations.of(context)!
                            .translate('completed')
                            .toString(),
                        subtitle: AppLocalizations.of(context)!
                            .translate('submit_invoice_email_sent_success_msg')
                            .toString(),
                        onPressed: () {
                          log("find log");

                          log(load_num.toString());
                          Navigator.of(dCtx).pop();
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () async {
                              // submitData(context);
                              // savePDFdata();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: HomeScreen.name),
                                      builder: (context) => const HomeScreen()),
                                  (Route<dynamic> route) => false);
                            },
                          );
                        },
                      ),
                    );
                  });
            } else {
              Utils.showErrorSnackBar(
                  message: platformResponse +
                      ".${AppLocalizations.of(context)!.translate('please_wait').toString()}",
                  context: context);
            }
          } else {
            progressSink.add(false);
            clearCommentAndEmail(pdfPath.length);
            platformResponse = AppLocalizations.of(context)!
                .translate('something_went_wrong')
                .toString();
            Utils.showErrorSnackBar(
                message: platformResponse, context: context);
            await Future.delayed(const Duration(seconds: 2));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: HomeScreen.name),
                    builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false);
          }
          isSent = false;
          log("isSent Last ********$isSent");
        }
      }
    } catch (error, stackTrace) {
      progressSink.add(false);
      debugPrint('sendInvoiceEmail Catch Error : $error');
      await Sentry.captureException(error,
          stackTrace: stackTrace, hint: 'sendInvoiceEmail final catch');
    }
  }

  void clearCommentAndEmail(int length) {
    if (length == 1) {
      AppString.commnetsaved = "";
      list.clear();
    }
  }

/*  Future<void> showInvoiceUploadDialog(
      BuildContext context, Invoice invoice, List<String> pdfPath) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CommonDialog(
              yesButtonText:
                  AppLocalizations.of(context)!.translate('ok').toString(),
              title: AppLocalizations.of(context)!
                  .translate(Platform.isAndroid
                      ? 'pdf_upload_message'
                      : 'pdf_upload_message_ios')
                  .toString(),
              isSingleButton: true,
              onPressed: () async {
                await _removeFileFromCache(context, invoice.loadNo, pdfPath[0]);
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings:
                          const RouteSettings(name: 'TriumphWebViewScreen'),
                      builder: (builder) => TriumphWebViewScreen(
                            params: WebViewParams(
                                username: '',
                                password: '',
                                url: AppPreference().triumphPayLink,
                                isFactorView: false),
                          )),
                );
              },
            ),
          );
        });
  }*/

  Future<void> _removeFileFromCache(
      BuildContext context, String loadNumber, String path) async {
    try {
      print("_removeFileFromCache Pdf Path file  $path");
      await FileUtil.deleteFile(File(path));
    } catch (e) {
      debugPrint('_removeFileFromCache:-  CATCH delete values ${e.toString()}');
    }
  }

/*  Future<void> _removeFileFromCache(
      BuildContext context, String loadNumber, String path) async {
    try {
      */ /*print("Pdf Path file  ${path}");
      File file = File(path);
      bool isExist = await file.exists();
      if (isExist) await file.delete();
      //android //com.app.pay4freight

      List<String> _list = _removeAllImageAtOnePlace();
      List<String> _pdflist = _removeAllPDFAtOnePlace();

      for (int i = 0; i < _list.length; i++) {
        if (_list[i].contains('com.app.pay4freight')) {
          File file = File(_list[i]);
          bool isExist = await file.exists();
          if (isExist) await file.delete();
        }
      }

      for (int i = 0; i < _pdflist.length; i++) {
        if (_list[i].contains('com.app.pay4freight')) {
          File file = File(_list[i]);
          bool isExist = await file.exists();
          if (isExist) await file.delete();
        }
      }
      // var appDir = (await getTemporaryDirectory()).path;
      //new Directory(appDir).delete(recursive: true);
      if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final files = File(directory.path);
        final isExists = await files.exists();
        if (isExists) {
          await files.delete(recursive: true);
        }
      }*/ /*
      var loadNumberInt = loadNumber;
      int value = await DataBaseHelper.instance.delete(loadNumberInt);
      debugPrint('email_testing:-  delete values $value');
    } catch (e) {
      debugPrint('email_testing:-  delete values ${e.toString()}');
    } finally {
      // Future.delayed(Duration(milliseconds: 1000), () {
      //   Navigator.pop(context);
      // });
      //

      checkIfLoadNumberValueIsExist(loadNumber, context);
    }
  }*/

  Future<void> _removeAllFileFromCache(
      BuildContext context, String loadNumber, List<String> allPdfs) async {
    try {
      List<String> _list = _removeAllImageAtOnePlace();

      for (int i = 0; i < _list.length; i++) {
        await FileUtil.deleteFile(File(_list[i]));
      }
      debugPrint(
          "_removeAllFileFromCache : All Pdf List : ${allPdfs.toString()}");
      if (allPdfs.isNotEmpty) {
        for (int i = 0; i < allPdfs.length; i++) {
          await FileUtil.deleteFile(File(allPdfs[i]));
        }
      }
      var loadNumberInt = loadNumber;
      int value = await DataBaseHelper.instance.delete(loadNumberInt);
      debugPrint('_removeAllFileFromCache:- TRY delete values $value');
    } catch (e) {
      debugPrint(
          '_removeAllFileFromCache:- CATCH delete values ${e.toString()}');
    }
  }

/*  void _removeAllFileFromCache(BuildContext context, String loadNumber) async {
    try {
      //android //com.app.pay4freight

      List<String> _list = _removeAllImageAtOnePlace();
      List<String> _pdflist = _removeAllPDFAtOnePlace();

      for (int i = 0; i < _list.length; i++) {
        if (_list[i].contains('com.app.pay4freight')) {
          File file = File(_list[i]);
          bool isExist = await file.exists();
          if (isExist) await file.delete();
        }
      }

      for (int i = 0; i < _pdflist.length; i++) {
        if (_list[i].contains('com.app.pay4freight')) {
          File file = File(_list[i]);
          bool isExist = await file.exists();
          if (isExist) await file.delete();
        }
      }
      // var appDir = (await getTemporaryDirectory()).path;
      //new Directory(appDir).delete(recursive: true);
      if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final files = File(directory.path);
        final isExists = await files.exists();
        if (isExists) {
          await files.delete(recursive: true);
        }
      }
      var loadNumberInt = loadNumber;
      int value = await DataBaseHelper.instance.delete(loadNumberInt);
      debugPrint('email_testing:-  delete values $value');
    } catch (e) {
      debugPrint('email_testing:-  delete values ${e.toString()}');
    } finally {
      // Future.delayed(Duration(milliseconds: 1000), () {
      //   Navigator.pop(context);
      // });
      //

      checkIfLoadNumberValueIsExist(loadNumber, context);
    }
  }*/

  bool _checkIfDataIsExist() {
    bool isDataExist = false;
    for (int i = 0; i < _imageList.length; i++) {
      SubmitInvoiceDetailModel _submitInvoiceDetailModel = _imageList[i];
      debugPrint(
          'checkIfDataIsExistTesting:-   $i ${_submitInvoiceDetailModel.count}');
      if (_submitInvoiceDetailModel.count! > 0) {
        isDataExist = true;
        return true;
      }
    }
    debugPrint('checkIfDataIsExistTesting:-   true');
    return isDataExist;
  }

  Future<List<String>> _getAllImageAtOnePlace() async {
    log("1 _getAllImageAtOnePlace 1");
    List<String> _imageListAll = [];
    for (int i = 0; i < _imageList.length; i++) {
      SubmitInvoiceDetailModel _submitInvoiceDetailModel = _imageList[i];
      if (_submitInvoiceDetailModel.imagePath != 'null') {
        List<String> _images = _submitInvoiceDetailModel.imagePath!
            .split(",")
            .map((e) => e.trim())
            .toList();
        _imageListAll.addAll(_images);
      }
      print(
          "debuging  _getAllImageAtOnePlace 2 ${_imageListAll.length} ${_submitInvoiceDetailModel.imagePath}");

      if (_submitInvoiceDetailModel.title == AppString.invoice) {
        if (_submitInvoiceDetailModel.imagePath != 'null') {
          List<String> _images = _submitInvoiceDetailModel.imagePath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_images.isNotEmpty && _images.first.isNotEmpty) {
            invoiceAllPdfsList = await _getPdfPath(
                _submitInvoiceDetailModel.loadNumber! + AppString.invoice,
                _images);
            print(
                "SingleImageList  invoiceAllPdfsList   ${invoiceAllPdfsList.length} _images ${_images.length} ");
          } else {
            print(
                "SingleImageList  invoiceAllPdfsList empty ${_images.length}");
          }
        }
        print("debuging  _getAllImageAtOnePlace3");
      } else if (_submitInvoiceDetailModel.title == AppString.bol) {
        if (_submitInvoiceDetailModel.imagePath != 'null') {
          List<String> _images = _submitInvoiceDetailModel.imagePath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_images.isNotEmpty && _images.first.isNotEmpty) {
            bolAllPdfsList = await _getPdfPath(
                _submitInvoiceDetailModel.loadNumber! + AppString.bol, _images);
            print(
                "SingleImageList  bolAllPdfsList   ${bolAllPdfsList.length} _images ${_images.length} ");
          } else {
            print("SingleImageList  bolAllPdfsList empty ${_images.length}");
          }
        }
        print("debuging  _getAllImageAtOnePlace 4");
      } else if (_submitInvoiceDetailModel.title ==
          AppString.rate_confirmation) {
        if (_submitInvoiceDetailModel.imagePath != 'null') {
          List<String> _images = _submitInvoiceDetailModel.imagePath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_images.isNotEmpty && _images.first.isNotEmpty) {
            rateConfAllPdfsList = await _getPdfPath(
                _submitInvoiceDetailModel.loadNumber! + "rate_confirmation",
                _images);
            print(
                "SingleImageList  rateConfAllPdfsList   ${rateConfAllPdfsList.length} _images ${_images.length} ");
          } else {
            print(
                "SingleImageList  rateConfAllPdfsList empty ${_images.length}");
          }
        }
      } else if (_submitInvoiceDetailModel.title == AppString.lumper_receipt) {
        if (_submitInvoiceDetailModel.imagePath != 'null') {
          List<String> _images = _submitInvoiceDetailModel.imagePath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_images.isNotEmpty && _images.first.isNotEmpty) {
            lumperRecAllPdfsList = await _getPdfPath(
                _submitInvoiceDetailModel.loadNumber! + "lumper_receipt",
                _images);
            print(
                "SingleImageList  lumperRecAllPdfsList   ${lumperRecAllPdfsList.length} _images ${_images.length} ");
          } else {
            print(
                "SingleImageList  lumperRecAllPdfsList empty ${_images.length}");
          }
        }
      } else if (_submitInvoiceDetailModel.title == AppString.others) {
        if (_submitInvoiceDetailModel.imagePath != 'null') {
          List<String> _images = _submitInvoiceDetailModel.imagePath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_images.isNotEmpty && _images.first.isNotEmpty) {
            otherAllPdfsList = await _getPdfPath(
                _submitInvoiceDetailModel.loadNumber! + AppString.others,
                _images);
            print(
                "SingleImageList  otherAllPdfsList   ${otherAllPdfsList.length} _images ${_images.length} ");
          } else {
            print("SingleImageList  otherAllPdfsList empty ${_images.length}");
          }
        }
      }
    }

    if (_imageListAll.isNotEmpty && _imageListAll.first.isNotEmpty) {
      debugPrint(
          'image_list_all_testing:-   ${_imageListAll.length} first  ${_imageListAll.first}');
    } else {
      _imageListAll.clear();
      debugPrint('image_list_all_testing:-   empty');
    }

    return _imageListAll;
  }

  List<String> _removeAllImageAtOnePlace() {
    List<String> _imageListAll = [];
    for (int i = 0; i < _imageList.length; i++) {
      SubmitInvoiceDetailModel _submitInvoiceDetailModel = _imageList[i];
      if (_submitInvoiceDetailModel.imagePath != 'null') {
        List<String> _images = _submitInvoiceDetailModel.imagePath!
            .split(",")
            .map((e) => e.trim())
            .toList();
        _imageListAll.addAll(_images);
      }
    }

    if (_imageListAll.isNotEmpty && _imageListAll.first.isNotEmpty) {
      debugPrint(
          'image_list_all_testing:-   ${_imageListAll.length} first  ${_imageListAll.first}');
    } else {
      _imageListAll.clear();
      debugPrint('image_list_all_testing:-   empty');
    }
    return _imageListAll;
  }

  List<String> _removeAllPDFAtOnePlace() {
    List<String> _imageListAll = [];
    for (int i = 0; i < _imageList.length; i++) {
      SubmitInvoiceDetailModel _submitInvoiceDetailModel = _imageList[i];
      if (_submitInvoiceDetailModel.pdfFilesPath != 'null') {
        List<String> _images = _submitInvoiceDetailModel.pdfFilesPath!
            .split(",")
            .map((e) => e.trim())
            .toList();
        _imageListAll.addAll(_images);
      }
    }

    if (_imageListAll.isNotEmpty && _imageListAll.first.isNotEmpty) {
      debugPrint(
          'image_list_all_testing:-   ${_imageListAll.length} first  ${_imageListAll.first}');
    } else {
      _imageListAll.clear();
      debugPrint('image_list_all_testing:-   empty');
    }
    return _imageListAll;
  }

  Future<List<String>> _getAllPdfAtOnePlace() async {
    log("_getAllPdfAtOnePlace()");
    List<String> _pdfListAll = [];
    for (int i = 0; i < _imageList.length; i++) {
      SubmitInvoiceDetailModel _submitInvoiceDetailModel = _imageList[i];
      if (_submitInvoiceDetailModel.pdfFilesPath != 'null') {
        List<String> _pdf = _submitInvoiceDetailModel.pdfFilesPath!
            .split(",")
            .map((e) => e.trim())
            .toList();
        _pdfListAll.addAll(_pdf);
      }
      if (_submitInvoiceDetailModel.title == AppString.invoice) {
        if (_submitInvoiceDetailModel.pdfFilesPath != 'null') {
          List<String> _pdf = _submitInvoiceDetailModel.pdfFilesPath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_pdf.isNotEmpty && _pdf.first.contains("pdf")) {
            invoiceAllPdfsList.addAll(_pdf);
            print(
                "SinglePDFList  invoiceAllPdfsList   ${invoiceAllPdfsList.length} _pdf ${_pdf.length} ");
          } else {
            print("SinglePDFList  invoiceAllPdfsList empty ${_pdf.length}");
          }
        }
      } else if (_submitInvoiceDetailModel.title == AppString.bol) {
        if (_submitInvoiceDetailModel.pdfFilesPath != 'null') {
          List<String> _pdf = _submitInvoiceDetailModel.pdfFilesPath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_pdf.isNotEmpty && _pdf.first.contains("pdf")) {
            bolAllPdfsList.addAll(_pdf);
            print(
                "SinglePDFList  bolAllPdfsList   ${bolAllPdfsList.length} _pdf ${_pdf.length} _pdf name ${_pdf[0]} ");
          } else {
            print("SinglePDFList  bolAllPdfsList empty ${_pdf.length}");
          }
        }
      } else if (_submitInvoiceDetailModel.title ==
          AppString.rate_confirmation) {
        if (_submitInvoiceDetailModel.pdfFilesPath != 'null') {
          List<String> _pdf = _submitInvoiceDetailModel.pdfFilesPath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_pdf.isNotEmpty && _pdf.first.contains("pdf")) {
            rateConfAllPdfsList.addAll(_pdf);
            print(
                "SinglePDFList  rateConfAllPdfsList   ${rateConfAllPdfsList.length} _pdf ${_pdf.length} _pdf name ${_pdf[0]} ");
          } else {
            print("SinglePDFList  rateConfAllPdfsList empty ${_pdf.length}");
          }
        }
      } else if (_submitInvoiceDetailModel.title == AppString.lumper_receipt) {
        if (_submitInvoiceDetailModel.pdfFilesPath != 'null') {
          List<String> _pdf = _submitInvoiceDetailModel.pdfFilesPath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_pdf.isNotEmpty && _pdf.first.contains("pdf")) {
            lumperRecAllPdfsList.addAll(_pdf);
            print(
                "SinglePDFList  lumperRecAllPdfsList   ${lumperRecAllPdfsList.length} _pdf ${_pdf.length} _pdf name ${_pdf[0]} ");
          } else {
            print("SinglePDFList  lumperRecAllPdfsList empty ${_pdf.length}");
          }
        }
      } else if (_submitInvoiceDetailModel.title == AppString.others) {
        if (_submitInvoiceDetailModel.pdfFilesPath != 'null') {
          List<String> _pdf = _submitInvoiceDetailModel.pdfFilesPath!
              .split(",")
              .map((e) => e.trim())
              .toList();
          if (_pdf.isNotEmpty && _pdf.first.contains("pdf")) {
            otherAllPdfsList.addAll(_pdf);
            print(
                "SinglePDFList  otherAllPdfsList   ${otherAllPdfsList.length} _pdf ${_pdf.length} _pdf name ${_pdf[0]} ");
          } else {
            print("SinglePDFList  otherAllPdfsList empty ${_pdf.length}");
          }
        }
      }
    }
    debugPrint('pdf_list_all_testing:-   ${_pdfListAll.length}');
    return _pdfListAll;
  }

  List<String> _getAllPdfSizeAtOnePlace() {
    List<String> _pdfSizeListAll = [];
    for (int i = 0; i < _imageList.length; i++) {
      SubmitInvoiceDetailModel _submitInvoiceDetailModel = _imageList[i];
      if (_submitInvoiceDetailModel.pdfFilesPathSize != 'null') {
        List<String> _pdf = _submitInvoiceDetailModel.pdfFilesPathSize!
            .split(",")
            .map((e) => e.trim())
            .toList();
        _pdfSizeListAll.addAll(_pdf);
      }
    }
    debugPrint('pdf_list_all_testing:-   ${_pdfSizeListAll.length}');
    return _pdfSizeListAll;
  }

  Future<List<String>> _getPdfPath(
      String loadNumber, List<String> _allList) async {
    log("1000");
    try {
      List<String> _pathsList = [];
      String dirPath = await FileUtil.getDirPath();
      int fileSize = 0;
      int startFilesIndex = 0;
      int pdfCount = 1;
      print("_getPdfPath debugging 1");

      for (int i = 0; i < _allList.length; i++) {
        int singleFileSize = File(_allList[i]).lengthSync();
        print(
            "_getPdfPath debugging for loop start 1 : index :$i , singleFileSize:$singleFileSize , fileSize : $fileSize");
        fileSize = fileSize + singleFileSize;
        print(
            "_getPdfPath debugging for loop start 2 : index :$i , singleFileSize:$singleFileSize , fileSize : $fileSize");
        if ((fileSize < imgPdfFileSizeFull) && (_allList.length - 1 == i)) {
          String fileName = await getFileName(loadNumber, pdfCount);
          fileName = "$dirPath/$fileName";
          await FileUtil.deleteFile(File(fileName));
          List<String> subList = _allList.sublist(startFilesIndex, i + 1);
          Map<String, dynamic> _map = <String, dynamic>{};
          _map = {
            "data": subList,
            "path": fileName,
          };

          String? path = await compute(_makePdfComputeFunction, _map);
          _pathsList.add(path!);
          startFilesIndex = i;
          pdfCount++;
          fileSize = 0;
          print("_getPdfPath debugging 3");
        } else if (fileSize >= imgPdfFileSizeFull) {
          // 20000000
          String fileName = await getFileName(loadNumber, pdfCount);
          fileName = "$dirPath/$fileName";
          await FileUtil.deleteFile(File(fileName));
          List<String> subList = _allList.sublist(startFilesIndex, i);
          Map<String, dynamic> _map = <String, dynamic>{};
          _map = {
            "data": subList,
            "path": fileName,
          };

          String? path = await compute(_makePdfComputeFunction, _map);
          _pathsList.add(path!);
          startFilesIndex = i;
          i--;
          pdfCount++;
          fileSize = 0;
          //}
          print("_getPdfPath debugging 4");
        }
      }

      return _pathsList;
    } catch (e, stackTrace) {
      print("_getPdfPath Error : $e ");
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: 'SubmitInvoiceDetailBloc _getPdfPath catchError');
      return [];
    }
  }

/*  Future<List<String>?> _getPdfPathMergedFile(
      String loadNumber, List<String> _allList) async {
    try {
      List<String> _pathsList = [];
      String dirPath = "";
      if (Platform.isAndroid) {
        Directory? appDocDir = await getExternalStorageDirectory();
        dirPath = appDocDir!.path;
      } else {
        Directory appDocDir = await getLibraryDirectory();
        dirPath = appDocDir.path;
        //getApplicationDocumentsDirectory
        //getLibraryDirectory
      }
      debugPrint('_getPdfPathMergedFile app_dir_is:-   $dirPath');
      int fileSize = 0;
      int startFilesIndex = 0;
      int pdfCount = 1;
      var singleFileSize = 0;
      print("_getPdfPathMergedFile totalPdfFiles ${_allList.length}");
      for (int i = 0; i < _allList.length; i++) {
        //singleFileSize =  File(_allList[i]).lengthSync();
        File file = File(_allList[i]);
        if (file.existsSync()) {
          singleFileSize = file.lengthSync();
          print("singleFile*****  ${_allList[i]} Size $singleFileSize");
          int? _pdfFileSize;
          if (_pdfFileSize != null) {
            if (singleFileSize < fileSizeFull &&
                (_pdfFileSize + singleFileSize) < fileSizeFull) {
              _pdfFileSize = File(_allList[i]).lengthSync();
              singleFileSize = 0;
            }
          } else {
            _pdfFileSize = File(_allList[i]).lengthSync();
          }
          fileSize = (fileSize + _pdfFileSize);
          print("****FileSize********  $fileSize $i  FileName ${_allList[i]}");
        } else {
          print("****existsSync******** $i  FileName ${_allList[i]}");
          // await  copyFile(_allList[i]);
        }

        if (fileSize < fileSizeFull && _allList.length - 1 == i) {
          print("_getPdfPathMergedFile if part");
          String fileName = await getFileName(loadNumber, pdfCount);
          fileName = "$dirPath/$fileName";
          debugPrint('file_path_is_testing if  $fileName');
          File file = File(fileName);
          bool isExist = await file.exists();
          if (isExist) await file.delete();
          List<String> subList = _allList.sublist(startFilesIndex, ++i);
          debugPrint('sublist main :-  ${subList.length}');
          await mergeMultiplePDF(fileName, subList);
          _pathsList.add(fileName);
          debugPrint("path:-   $fileName");
          startFilesIndex = i;
          pdfCount++;
          fileSize = 0;
        } else if (fileSize >= fileSizeFull) {
          print("_getPdfPathMergedFile else if part");
          String fileName = await getFileName(loadNumber, pdfCount);
          fileName = "$dirPath/$fileName";
          debugPrint('file_path_is_testing else if $fileName');
          File file = File(fileName);
          bool isExist = await file.exists();
          if (isExist) await file.delete();

          List<String> subList = _allList.sublist(startFilesIndex, i);
          debugPrint('sublist:-  ${subList.length}');
          await mergeMultiplePDF(fileName, subList);
          _pathsList.add(fileName);
          debugPrint("path:-   $fileName");
          startFilesIndex = i;
          pdfCount++;
          fileSize = 0;
        }
        //}
      }

      return _pathsList;
    } catch (e) {
      print("_getPdfPathMergedFile ExceptionMerge $e ");
      return null;
    }
  }*/

  Future<List<String>?> _getPdfPathMergedFile(
      String loadNumber, List<String> _allList) async {
    log("2000");
    log(" loadNumber $loadNumber");
    try {
      List<String> _pathsList = [];
      String dirPath = await FileUtil.getDirPath();
      log('_getPdfPathMergedFile app_dir_is:-   $dirPath');
      int fileSize = 0;
      int startFilesIndex = 0;
      int pdfCount = 1;
      print("_getPdfPathMergedFile totalPdfFiles ${_allList.length}");
      for (int i = 0; i < _allList.length; i++) {
        int singleFileSize = File(_allList[i]).lengthSync();
        print(
            "_getPdfPathMergedFile debugging for loop start 1 : index :$i , singleFileSize:$singleFileSize , fileSize : $fileSize");
        fileSize = fileSize + singleFileSize;
        print(
            "_getPdfPathMergedFile debugging for loop start 1 : index :$i , singleFileSize:$singleFileSize , fileSize : $fileSize");

        if ((fileSize < fileSizeFull) && (_allList.length - 1 == i)) {
          print("_getPdfPathMergedFile if part");
          String fileName = await getFileName(loadNumber, pdfCount);
          fileName = "$dirPath/$fileName";
          debugPrint('file_path_is_testing if  $fileName');
          await FileUtil.deleteFile(File(fileName));
          List<String> subList = _allList.sublist(startFilesIndex, i + 1);
          debugPrint("ALL LIST IF : ${_allList.toString()}");
          debugPrint(
              'sublist main :-  ${subList.length} ,startFilesIndex : $startFilesIndex , index : $i ');
          log('sublist main data:-  ${subList.toString()} ');
          bool isMergerSuccess = await mergeMultiplePDF(fileName, subList);
          if (!isMergerSuccess) {
            log("mearge no comp");
            return [];
          }
          _pathsList.add(fileName);
          debugPrint("path:-   $fileName");
          startFilesIndex = i;
          pdfCount++;
          fileSize = 0;
        } else if (fileSize >= fileSizeFull) {
          log("_getPdfPathMergedFile else if part");
          String fileName = await getFileName(loadNumber, pdfCount);
          fileName = "$dirPath/$fileName";
          debugPrint('file_path_is_testing else if $fileName');
          await FileUtil.deleteFile(File(fileName));
          List<String> subList = _allList.sublist(startFilesIndex, i);
          log("ALL LIST ELSE : ${_allList.toString()}");
          log('sublist:-  ${subList.length} ,startFilesIndex : $startFilesIndex , index : $i ');
          debugPrint('sublist data:-  ${subList.toString()} ');
          bool isMergerSuccess = await mergeMultiplePDF(fileName, subList);
          if (!isMergerSuccess) {
            return [];
          }
          _pathsList.add(fileName);
          log("path:-   $fileName");
          startFilesIndex = i;
          i--;
          pdfCount++;
          fileSize = 0;
        }
      }
      return _pathsList;
    } catch (e, stackTrace) {
      print("_getPdfPathMergedFile ExceptionMerge $e ");
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: 'SubmitInvoiceDetailBloc _getPdfPathMergedFile catchError');
      return [];
    }
  }

  static Future copyFile(String result) async {
    log("3000");
    File file = File(result);
    final documentPath = (await getApplicationDocumentsDirectory()).path;
    file = await file.copy('$documentPath/${path.basename(file.path)}');
    print("Test path ${file.path}");
    print("Test existsSync ${file.existsSync()}");
    return file;
  }

  Future<String> getFileName(String? loadNumber, int? pdfCount) async {
    log("4000");
    String? companyName = await getCompanyName();
    // return '${loadNumber ?? ""}${companyName}_$pdfCount.pdf'
    //     .replaceAll(',', '');
    return '${loadNumber ?? ""}$companyName.pdf'.replaceAll(',', '');
  }

  Future<String> getEmailSubject(Invoice invoice, int noOfEmails) async {
    log("5000");
    // String? companyName = await getCompanyName();
    String subject =
        '${invoice.loadNo}_${invoice.companyName}_${invoice.fundingType}_$noOfEmails';
    // return '${loadNumber ?? ""}${companyName}_${++pos}'.replaceAll(',', '');
    return subject.replaceAll(',', '');
  }

  String getEmailBody(Invoice invoice) {
    log("7000");
    String fuelAdvance = invoice.isFuelAdvance
        ? AppString.fuelAdvanceRequested
        : AppString.notRequested;
    var content =
        '''<div style='background:#fff;text-align:center;padding:20px;border:1px solid #e3e5e1'><img width='180' src='${Constant.email_logo}'/></div>
           <div style='min-height:28px'>
           <div style='padding:24px 3.6% 24px;background:#fff;border:1px solid #e3e5e1'>
           <div style='text-align:left;'>${AppString.companyName.toUpperCase()} = ${invoice.companyName}
           <br />${AppString.companyEmail.toUpperCase()} = ${invoice.companyEmail}
           <br />${AppString.customerNameBroker.toUpperCase()} = ${invoice.customerName}
           <br/>${AppString.customerLoadHash.toUpperCase()} = ${invoice.loadNo}
           <br/>${AppString.invoiceAmount.toUpperCase()} = \$${invoice.amount}
           <br/>${AppString.fundingType.toUpperCase()} = ${invoice.fundingType}
           <br/>${AppString.fuelAdvance.toUpperCase()} = $fuelAdvance
           <br/>${AppString.comments.toUpperCase()} = ${invoice.comment}
           <br/>${AppString.name.toUpperCase()} = ${invoice.username} <br/></div></div></div>''';
    return content;
  }

/*  String getEmailBody(Invoice invoice) {
    String fuelAdvance = invoice.isFuelAdvance
        ? AppString.fuelAdvanceRequested
        : AppString.notRequested;
    return '''
     ${AppString.companyName.toUpperCase()} : ${invoice.companyName}
     ${AppString.companyEmail.toUpperCase()} : ${invoice.companyEmail}
     ${AppString.customerNameBroker.toUpperCase()} : ${invoice.customerName}
     ${AppString.customerLoadHash.toUpperCase()} : ${invoice.loadNo}
     ${AppString.invoiceAmount.toUpperCase()} : \$${invoice.amount}
     ${AppString.fundingType.toUpperCase()} : ${invoice.fundingType}
     ${AppString.fuelAdvance.toUpperCase()} : $fuelAdvance
     ${AppString.comments.toUpperCase()} : ${invoice.comment}
     ${AppString.name.toUpperCase()} : ${invoice.username}
    ''';
  }*/

  Future<String> getPdfFileName(String? loadNumber, int pos) async {
    log("8000");
    String? companyName = await getCompanyName();
    return '${loadNumber ?? ""}${companyName}_${++pos}'.replaceAll(',', '');
  }

  static Future<String?> _makePdfComputeFunction(
      Map<String, dynamic> value) async {
    log("9000");
    try {
      log("_makePdfComputeFunction");
      String _path = value['path'];

      List<String> _pathList = value['data'];

      final PdfDocument document = PdfDocument();
      _pathList.forEach((element) async {
        log("Add image data");
        log(document.toString());
        final Uint8List imageData = File(element).readAsBytesSync();
        //Adds a page to the document
        PdfPage page = document.pages.add();
        page.graphics.drawImage(
            PdfBitmap(imageData),
            Rect.fromLTWH(
                0, 0, page.getClientSize().width, page.getClientSize().height));
      });

      File finalOutput = await File(_path).writeAsBytes(await document.save());
      document.dispose();
      log(finalOutput.path.toString());
      return finalOutput.path;
    } catch (e) {
      debugPrint('_makePdfComputeFunction:-  ${e.toString()}    ');
      return null;
    }
  }

  Future<String> getCompanyName() async {
    log("11000");
    log("retune company name");
    String companyName = AppPreference().userCompany;

    if (companyName.isNotEmpty) {
      companyName = "_${companyName.replaceAll(' ', '-').toLowerCase()}";
    } else {
      companyName = "";
    }

    return companyName;
  }
}
