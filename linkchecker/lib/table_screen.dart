import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

class TableScreen extends StatefulWidget {
  final List<Map<String, dynamic>> excelData;
  final int maxLinks;

  TableScreen({Key? key, required this.excelData, required this.maxLinks})
      : super(key: key);

  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  HDTRefreshController _hdtRefreshController = HDTRefreshController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Data Table'),
        backgroundColor: Colors.black,
      ),
      body: _buildTable(screenWidth),
    );
  }
  //

  Widget _buildTable(double screenWidth) {
    return HorizontalDataTable(
      leftHandSideColumnWidth: 0,
      rightHandSideColumnWidth: screenWidth,
      isFixedHeader: true,

      headerWidgets: _getTitleWidget(),
      leftSideItemBuilder: _generateFirstColumnRow,
      rightSideItemBuilder: _generateRightHandSideColumnRow,
      itemCount: widget.excelData.length,
      rowSeparatorWidget: const Divider(
        color: Colors.grey,
        height: 1.0,
        thickness: 0.0,
      ),
      htdRefreshController: _hdtRefreshController,
      enablePullToRefresh: false,
      leftHandSideColBackgroundColor: Colors.black, // For dark mode background
      rightHandSideColBackgroundColor: Colors.black,
    );
  }

  List<Widget> _getTitleWidget() {
    List<Widget> titleWidgets = [
      _getTitleItemWidget('Actions', 100),
      _getTitleItemWidget('Actions', 100),
      _getTitleItemWidget('PBN Name', 200),
      _getTitleItemWidget('Category', 100),
      _getTitleItemWidget('Total Links', 100),
    ];

    for (int i = 0; i < widget.maxLinks; i++) {
      titleWidgets.add(_getTitleItemWidget('Link ${i + 1}', 200));
    }
    return titleWidgets;
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text(widget.excelData[index]['Actions'] ?? ''),
      width: 100,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    List<Widget> rowWidgets = [
      Container(
        child: Text(widget.excelData[index]['Actions'] ?? 'Edit | Delete'),
        width: 100,
        height: 52,
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
      ),
      Container(
        child: Text(widget.excelData[index]['PBN Name'] ?? ''),
        width: 200,
      ),
      Container(
        child: Text(widget.excelData[index]['Category'] ?? ''),
        width: 100,
      ),
      Container(
        child: Text('${widget.excelData[index]['Total Links']}'),
        width: 100,
      ),
    ];

    List<String> links = widget.excelData[index]['Links'] ?? [];
    rowWidgets.addAll(List<Widget>.generate(
        widget.maxLinks,
        (i) => Container(
              child: Text(i < links.length ? links[i] : 'N/A'),
              width: 200,
            )));

    return Row(children: rowWidgets);
  }

  double _calculateRightHandSideColumnWidth() {
    // Adjust based on your content, for example:
    return 200.00 +
        (100 * (3 + widget.maxLinks)); // PBN Name width + other columns
  }
}
