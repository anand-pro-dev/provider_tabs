import 'package:flutter/material.dart';
import 'package:pay4freight/screens/submit_invoice/model/post_submit_his.dart';
import 'package:pay4freight/screens/submit_invoice/submission_his_page_pdf.dart';

import '../../locale/AppLocalizations.dart';
import '../../network_helper/post_by_http.dart';
import '../../styles/text_styles.dart';
import '../../styles/widget/appbar.dart';

const kceramicWhite = const Color(0xfffbfafb);
const kbuttonRed = const Color(0xfffea52316);
const kbluecolor = const Color(0xff006da0);

class SubmissionHistoryPageScroll extends StatefulWidget {
  const SubmissionHistoryPageScroll({Key? key}) : super(key: key);

  @override
  State<SubmissionHistoryPageScroll> createState() =>
      _SubmissionHistoryPageScrollState();
}

class _SubmissionHistoryPageScrollState
    extends State<SubmissionHistoryPageScroll> {
  final int pageSize = 20; // Number of items per page
  int currentPage = 0; // Current page number
  List<Data>? dataList = []; // List of data
  bool isLoading = false; // Indicates if data is being loaded
  bool hasMoreData = true; // Indicates if there is more data available

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiServices().postDATA(currentPage);

      if (response != null && response.data != null) {
        final List<Data> newData = response.data!;

        setState(() {
          dataList!.addAll(newData);
          isLoading = false;
          currentPage++;

          if (newData.length < pageSize) {
            hasMoreData = false;
          }
        });
      } else {
        throw Exception('No data available');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildListItem(Data item) {
    String inputDate = item.invDate ?? '';
    DateTime dateTime = DateTime.tryParse(inputDate) ?? DateTime.now();
    String formattedDate =
        "${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}-${dateTime.year.toString().substring(2)}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black38,
              blurRadius: 0.2,
              offset: Offset(0.0, 0.5),
            ),
          ],
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(
                  pageUri: item.pdfs.toString(),
                  loadnum: item.loadNumber.toString(),
                ),
              ),
            );
          },
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/images/pdf_imge.jpg"),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (AppLocalizations.of(context)
                          ?.translate('load_number_with_hash') ??
                      'Load Number with Hash'),
                  style: TextStyles.smallTitle(),
                ),
                const Text(" : "),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    item.loadNumber ?? '',
                    softWrap: false,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedDate,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("\$ "),
                Text(item.amount ?? " 0"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: kbluecolor,
      ),
    );
  }

  Widget _buildEndOfList() {
    return Center(
      child: Text(
        (AppLocalizations.of(context)?.translate('no_record_found') ??
            'No Record Found'),
        style: TextStyles.medium(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(
        title: AppLocalizations.of(context)!
            .translate('submission_history_addon')
            .toString()
            .toUpperCase(),
      ),
      backgroundColor: kceramicWhite,
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading &&
                    hasMoreData &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  fetchData();
                  return true;
                }
                return false;
              },
              child: ListView.builder(
                itemCount: dataList!.length + 1,
                itemBuilder: (context, index) {
                  if (index < dataList!.length) {
                    return _buildListItem(dataList![index]);
                  } else if (isLoading) {
                    return _buildLoadingIndicator();
                  }
                  // else {
                  //   return _buildEndOfList();
                  // }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
