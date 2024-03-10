import 'package:flutter/material.dart';

import '../../providers/filters_provider.dart';

class BuyerFilterByProducedDatePage extends StatefulWidget {
  const BuyerFilterByProducedDatePage(
      {super.key,
      required this.searchTerm,
      required this.productsProducedDatesList});
  final String searchTerm;
  final List productsProducedDatesList;

  @override
  State<BuyerFilterByProducedDatePage> createState() =>
      _BuyerFilterByProducedDatePageState();
}

class _BuyerFilterByProducedDatePageState
    extends State<BuyerFilterByProducedDatePage> {
  // bool isLoading = true;
  // late Uri getProductProducedDatesUrl;

  // List<DateTime> productsProducedDatesList = [];

  late TextEditingController _startProducedDateController,
      _endProducedDateController;

  // void getProductsProducedDatesList() {
  //   http.get(
  //     getProductProducedDatesUrl,
  //     headers: {'Content-Type': 'application/json'},
  //   ).then((response) {
  //     if (response.statusCode == 200) {
  //       var getProductProducedDatesResp = json.decode(response.body);
  //       print(getProductProducedDatesResp);
  //       if (getProductProducedDatesResp['message'] ==
  //           "Products produced dates received") {
  //         for (int i = 0;
  //             i < getProductProducedDatesResp['producedDatesList'].length;
  //             i++) {
  //           productsProducedDatesList.add(
  //             DateTime.parse(
  //               getProductProducedDatesResp['producedDatesList'][i]['_id'],
  //             ).toLocal(),
  //           );
  //         }
  //         // productsProducedDatesList.sort(
  //         //   (date1, date2) {
  //         //     if (date1.isBefore(date2)) {
  //         //       return -1;
  //         //     } else if (date1.isAfter(date2)) {
  //         //       return 1;
  //         //     } else {
  //         //       return 0;
  //         //     }
  //         //   },
  //         // );

  //         if (producedDateRangeList[0] != 0) {
  //           _startProducedDateController.text =
  //               "${producedDateRangeList[0].day}/${producedDateRangeList[0].month}/${producedDateRangeList[0].year}";
  //         } else {
  //           producedDateRangeList[0] = productsProducedDatesList.first;
  //           _startProducedDateController.text =
  //               "${productsProducedDatesList.first.day}/${productsProducedDatesList.first.month}/${productsProducedDatesList.first.year}";
  //         }

  //         if (producedDateRangeList[1] != 0) {
  //           _endProducedDateController.text =
  //               "${availableFromDateRangeList[1].day}/${availableFromDateRangeList[1].month}/${availableFromDateRangeList[1].year}";
  //         } else {
  //           producedDateRangeList[1] = productsProducedDatesList.last;
  //           _endProducedDateController.text =
  //               "${productsProducedDatesList.last.day}/${productsProducedDatesList.last.month}/${productsProducedDatesList.last.year}";
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
    // getProductProducedDatesUrl = Uri.https(
    //   authority,
    //   'api/common/getProductProducedDatesList',
    //   {"searchTerm": widget.searchTerm},
    // );
    _startProducedDateController = TextEditingController(
        text:
            '${widget.productsProducedDatesList.first.day}/${widget.productsProducedDatesList.first.month}/${widget.productsProducedDatesList.first.year}');
    _endProducedDateController = TextEditingController(
        text:
            '${widget.productsProducedDatesList.last.day}/${widget.productsProducedDatesList.last.month}/${widget.productsProducedDatesList.last.year}');
    // getProductsProducedDatesList();
  }

  @override
  void dispose() {
    super.dispose();
    _startProducedDateController.dispose();
    _endProducedDateController.dispose();
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
            controller: _startProducedDateController,
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: widget.productsProducedDatesList.first,
                firstDate: widget.productsProducedDatesList.first,
                lastDate: widget.productsProducedDatesList.last,
              ).then((value) {
                if (value != null) {
                  producedDateRangeList[0] = value;
                  setState(() {
                    _startProducedDateController.text =
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
            controller: _endProducedDateController,
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: widget.productsProducedDatesList.last,
                firstDate: widget.productsProducedDatesList.first,
                lastDate: widget.productsProducedDatesList.last,
              ).then((value) {
                if (value != null) {
                  producedDateRangeList[1] = value;
                  setState(() {
                    _endProducedDateController.text =
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
