import 'package:flutter/material.dart';

import '../../providers/filters_provider.dart';

class BuyerFilterByAvailableFromDatePage extends StatefulWidget {
  const BuyerFilterByAvailableFromDatePage(
      {super.key,
      required this.searchTerm,
      required this.productsAvailableDatesList});
  final String searchTerm;
  final List productsAvailableDatesList;

  @override
  State<BuyerFilterByAvailableFromDatePage> createState() =>
      _BuyerFilterByAvailableFromDatePageState();
}

class _BuyerFilterByAvailableFromDatePageState
    extends State<BuyerFilterByAvailableFromDatePage> {
  // bool isLoading = true;
  // late Uri getProductAvailableDatesUrl;

  // String startDateDisplay = '', endDateDisplay = '';

  // List<DateTime> productsAvailableDatesList = [];

  late TextEditingController _startAvailableDateController,
      _endAvailableDateController;

  // void getProductsProducedDatesList() {
  //   http.get(
  //     getProductAvailableDatesUrl,
  //     headers: {'Content-Type': 'application/json'},
  //   ).then((response) {
  //     if (response.statusCode == 200) {
  //       var getProductAvailableDatesResp = json.decode(response.body);
  //       print(getProductAvailableDatesResp);
  //       if (getProductAvailableDatesResp['message'] ==
  //           "Products available from dates received") {
  //         for (int i = 0;
  //             i < getProductAvailableDatesResp['availableFromDatesList'].length;
  //             i++) {
  //           productsAvailableDatesList.add(
  //             DateTime.parse(
  //               getProductAvailableDatesResp['availableFromDatesList'][i]
  //                   ['_id'],
  //             ).toLocal(),
  //           );
  //         }

  //         if (availableFromDateRangeList[0] != 0) {
  //           _startAvailableDateController.text =
  //               "${availableFromDateRangeList[0].day}/${availableFromDateRangeList[0].month}/${availableFromDateRangeList[0].year}";
  //         } else {
  //           availableFromDateRangeList[0] = productsAvailableDatesList.first;
  //           _startAvailableDateController.text =
  //               "${productsAvailableDatesList.first.day}/${productsAvailableDatesList.first.month}/${productsAvailableDatesList.first.year}";
  //         }

  //         if (availableFromDateRangeList[1] != 0) {
  //           _endAvailableDateController.text =
  //               "${availableFromDateRangeList[1].day}/${availableFromDateRangeList[1].month}/${availableFromDateRangeList[1].year}";
  //         } else {
  //           availableFromDateRangeList[1] = productsAvailableDatesList.last;
  //           _endAvailableDateController.text =
  //               "${productsAvailableDatesList.last.day}/${productsAvailableDatesList.last.month}/${productsAvailableDatesList.last.year}";
  //         }
  //       }
  //     }
  //   }).then((value) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // getProductAvailableDatesUrl = Uri.http(
    //   authority,
    //   'api/common/getProductAvailableDatesList',
    //   {"searchTerm": widget.searchTerm},
    // );
    _startAvailableDateController = TextEditingController(
        text:
            '${widget.productsAvailableDatesList.first.day}/${widget.productsAvailableDatesList.first.month}/${widget.productsAvailableDatesList.first.year}');
    _endAvailableDateController = TextEditingController(
        text:
            '${widget.productsAvailableDatesList.last.day}/${widget.productsAvailableDatesList.last.month}/${widget.productsAvailableDatesList.last.year}');
    // getProductsProducedDatesList();
  }

  @override
  void dispose() {
    super.dispose();
    _startAvailableDateController.dispose();
    _endAvailableDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        // isLoading
        //     ? const Center(
        //         child: CircularProgressIndicator(
        //           color: Color.fromARGB(110, 37, 143, 83),
        //         ),
        //       )
        //     :
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            "Select date range",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextFormField(
            maxLines: 1,
            minLines: 1,
            controller: _startAvailableDateController,
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: widget.productsAvailableDatesList.first,
                firstDate: widget.productsAvailableDatesList.first,
                lastDate: widget.productsAvailableDatesList.last,
              ).then((value) {
                if (value != null) {
                  availableFromDateRangeList.first= value;
                  setState(() {
                    _startAvailableDateController.text =
                        "${value.day}/${value.month}/${value.year}";
                  });
                }
              });
            },
            readOnly: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(left: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              labelText: 'Select Start Date',
            ),
          ),
        ),
        timeLineDecorationGenerator(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextFormField(
            maxLines: 1,
            minLines: 1,
            controller: _endAvailableDateController,
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: widget.productsAvailableDatesList.last,
                firstDate: widget.productsAvailableDatesList.first,
                lastDate: widget.productsAvailableDatesList.last,
              ).then((value) {
                if (value != null) {
                  availableFromDateRangeList.last = value;
                  setState(() {
                    _endAvailableDateController.text =
                        "${value.day}/${value.month}/${value.year}";
                  });
                }
              });
            },
            readOnly: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(left: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              labelText: 'Select End Date',
            ),
          ),
        ),
      ],
    );
  }
}

Widget timeLineDecorationGenerator() {
  return Center(
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 1.0, top: 5),
        child: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: const Color.fromARGB(168, 51, 118, 53),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      timeLineDecorationLineGenerator(),
      timeLineDecorationEmptyCircleGenerator(),
      timeLineDecorationLineGenerator(),
      timeLineDecorationEmptyCircleGenerator(),
      timeLineDecorationLineGenerator(),
      timeLineDecorationEmptyCircleGenerator(),
      timeLineDecorationLineGenerator(),
      timeLineDecorationEmptyCircleGenerator(),
      timeLineDecorationLineGenerator(),
      timeLineDecorationEmptyCircleGenerator(),
      timeLineDecorationLineGenerator(),
      Padding(
        padding: const EdgeInsets.only(left: 1.0, bottom: 5),
        child: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: const Color.fromARGB(168, 51, 118, 53),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ]),
  );
}

Widget timeLineDecorationEmptyCircleGenerator() {
  return Padding(
    padding: const EdgeInsets.only(left: 1.0),
    child: Container(
      height: 13,
      width: 13,
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(
            color: Color.fromARGB(110, 51, 118, 53),
            width: 2.5,
            style: BorderStyle.solid,
          ),
          left: BorderSide(
            color: Color.fromARGB(110, 51, 118, 53),
            width: 2.5,
            style: BorderStyle.solid,
          ),
          bottom: BorderSide(
            color: Color.fromARGB(110, 51, 118, 53),
            width: 2.5,
            style: BorderStyle.solid,
          ),
          right: BorderSide(
            color: Color.fromARGB(110, 51, 118, 53),
            width: 2.5,
            style: BorderStyle.solid,
          ),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget timeLineDecorationLineGenerator() {
  return Container(
    height: 23,
    width: 0,
    decoration: const BoxDecoration(
      border: Border(
        left: BorderSide(
            color: Color.fromARGB(255, 51, 118, 53), style: BorderStyle.solid),
      ),
    ),
  );
}
