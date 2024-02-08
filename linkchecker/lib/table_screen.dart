import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

class TableScreen extends StatefulWidget {
  final List<Map<String, dynamic>> excelData;
  int maxLinks;

  TableScreen({Key? key, required this.excelData, required this.maxLinks})
      : super(key: key);

  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  HDTRefreshController _hdtRefreshController = HDTRefreshController();
  Set<String> selectedCategories = {};
  Set<String> selectedTotalLinks = {};
  late List<Map<String, dynamic>> filteredData;
  TextEditingController searchController = TextEditingController();
  bool isFilterModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize filteredData with all data, then apply filters.
    filteredData = widget.excelData;
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _filterData();
  }

// Assuming prohibitedCombinations is defined at the class level
  Map<String, bool> prohibitedCombinations = {};

  void _filterData() {
    setState(() {
      String searchQuery = searchController.text.toLowerCase();
      Set<String> prohibitedLinks = Set<String>();

      if (isFilterModeEnabled && searchQuery.isNotEmpty) {
        // Step 1: Find all unique links that appear with the search query
        widget.excelData.forEach((data) {
          List<String> links = List.from(data['Links'] ?? []);
          if (links.any((link) => link.toLowerCase().contains(searchQuery))) {
            prohibitedLinks.addAll(links.map((link) => link
                .toLowerCase())); // Add all links from rows containing the search query
          }
        });
      }

      filteredData = widget.excelData.where((data) {
        bool searchMatch = true;
        if (isFilterModeEnabled) {
          List<dynamic> links = List.from(data['Links'] ?? [])
              .map((link) => link.toLowerCase())
              .toList();
          // Step 2: Check against all prohibited links
          searchMatch = !links.any((link) => prohibitedLinks.contains(link));
        } else {
          searchMatch = data.values.any(
              (value) => value.toString().toLowerCase().contains(searchQuery));
        }

        bool categoryMatch = selectedCategories.isEmpty ||
            selectedCategories.contains(data['Category']);
        bool totalLinksMatch = selectedTotalLinks.isEmpty ||
            selectedTotalLinks.contains(data['Total Links'].toString());

        return searchMatch && categoryMatch && totalLinksMatch;
      }).toList();
    });
  }

  // void _filterData() {
  //   setState(() {
  //     String searchQuery = searchController.text.toLowerCase();
  //     filteredData = widget.excelData.where((data) {
  //       // Check if data matches search query in any field
  //       bool searchMatch = data.values.any(
  //           (value) => value.toString().toLowerCase().contains(searchQuery));
  //       // Check if data matches selected category and total links filters
  //       bool categoryMatch = selectedCategories.isEmpty ||
  //           selectedCategories.contains(data['Category']);
  //       bool totalLinksMatch = selectedTotalLinks.isEmpty ||
  //           selectedTotalLinks.contains(data['Total Links'].toString());

  //       return searchMatch && categoryMatch && totalLinksMatch;
  //     }).toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Data Table'),
        backgroundColor: Colors.black,
        actions: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 100.0, left: 100.0),
              child: Container(
                width: 300,
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    fillColor: Colors.white24,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
                isFilterModeEnabled ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () {
              setState(() {
                isFilterModeEnabled = !isFilterModeEnabled;
                _filterData(); // Make sure to call _filterData to apply changes
              });
            },
          ),
        ],
      ),
      body: _buildTable(screenWidth),
    );
  }
  //

  Widget _buildTable(double screenWidth) {
    // List<Map<String, dynamic>> filteredData = widget.excelData.where((row) {
    //   // Apply 'Category' filter.
    //   bool categoryMatch = selectedCategories.isEmpty ||
    //       selectedCategories.contains(row['Category'].toString());

    //   // Apply 'Total Links' filter.
    //   bool totalLinksMatch = selectedTotalLinks.isEmpty ||
    //       selectedTotalLinks.contains(row['Total Links'].toString());

    //   return categoryMatch && totalLinksMatch;
    // }).toList();
    print("Current filteredData itemCount: ${filteredData.length}");
    return HorizontalDataTable(
      leftHandSideColumnWidth: 150,
      rightHandSideColumnWidth: screenWidth,
      isFixedHeader: true,
      headerWidgets: _getTitleWidget(),
      leftSideItemBuilder: _generateFirstColumnRow,
      rightSideItemBuilder: _generateRightHandSideColumnRow,
      itemCount: filteredData.length,
      rowSeparatorWidget: const Divider(
        color: Colors.grey,
        height: 1.0,
        thickness: 0.0,
      ),
      htdRefreshController: _hdtRefreshController,
      enablePullToRefresh: false,
      leftHandSideColBackgroundColor: Colors.black, // For dark mode background
      rightHandSideColBackgroundColor: Colors.black,
      horizontalScrollbarStyle: ScrollbarStyle(
          isAlwaysShown: true, radius: Radius.circular(10.0), thickness: 10.0),
      itemExtent: 55,
    );
  }

  List<Widget> _getTitleWidget() {
    List<Widget> titleWidgets = [
      _getTitleItemWidget('Actions', 150),
      _getTitleItemWidget('PBN Name', 200),
      _getTitleItemWidget('Category', 150,
          onFilterTap: () => _showFilterDialog('Category')),
      _getTitleItemWidget('Total Links', 150,
          onFilterTap: () => _showFilterDialog('Total Links')),
    ];

    for (int i = 0; i < widget.maxLinks; i++) {
      titleWidgets.add(_getTitleItemWidget('Link ${i + 1}', 200));
    }
    return titleWidgets;
  }

  Widget _getTitleItemWidget(String label, double width,
      {VoidCallback? onFilterTap}) {
    return Container(
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0), // Adjust padding as needed
      alignment: Alignment.centerLeft,
      color: Colors.black, // Assuming dark mode
      child: Row(
        children: [
          Text(label,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          if (onFilterTap != null)
            Padding(
              padding: EdgeInsets.only(
                  left: 5), // Reduced space between label and icon
              child: GestureDetector(
                onTap: onFilterTap,
                child: Icon(Icons.filter_list, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Set<String> getAllUniqueLinks() {
    Set<String> allLinks = {};
    for (var row in widget.excelData) {
      List<String> links = List.from(row['Links'] ?? []);
      allLinks.addAll(links);
    }
    return allLinks;
  }

  void _showEditDialog(BuildContext context, int rowIndex) {
    final row = filteredData[rowIndex];
    TextEditingController pbnNameController =
        TextEditingController(text: row['PBN Name']);
    TextEditingController categoryController =
        TextEditingController(text: row['Category']);
    List<TextEditingController> linkControllers = List.generate(
      row['Links'].length,
      (index) => TextEditingController(text: row['Links'][index]),
    );

    // This is a workaround to ensure the dialog is rebuilt with the new state.
    void rebuildDialog() {
      showDialog(
        context: context,
        builder: (context) => buildEditDialog(context, pbnNameController,
            categoryController, linkControllers, rowIndex, row),
      );
    }

    rebuildDialog();
  }

  Widget linkInputField(TextEditingController controller, Set<String> allLinks,
      BuildContext dialogContext) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return allLinks.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
        // Ensure the cursor is at the end of the input
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Sync the autocomplete's field controller with the external controller.
        fieldTextEditingController.text = controller.text;

        // Listen to changes in the text field and update the external controller.
        fieldTextEditingController.addListener(() {
          if (controller.text != fieldTextEditingController.text) {
            controller.text = fieldTextEditingController.text;
          }
        });

        return TextField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: 'Link',
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        );
      },
      // Optionally customize the options view if needed
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: 200, // Adjust width based on your UI requirement
              height: 80, // Adjust height based on your UI requirement
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEditDialog(
      BuildContext context,
      TextEditingController pbnNameController,
      TextEditingController categoryController,
      List<TextEditingController> linkControllers,
      int rowIndex,
      Map<String, dynamic> row) {
    Map<String, String> originalToNewLinks =
        {}; // Map to track original to new link changes
    return AlertDialog(
      title: const Text('Edit Row'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: pbnNameController,
                  decoration: const InputDecoration(labelText: 'PBN Name'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                ...List.generate(linkControllers.length, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: linkInputField(linkControllers[index],
                            getAllUniqueLinks(), context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() {
                          linkControllers.removeAt(index);
                          if (row['Links'].length > index) {
                            row['Links'].removeAt(index);
                          }
                        }),
                      ),
                    ],
                  );
                }),

                // ...List.generate(linkControllers.length, (index) {
                //   return Row(
                //     children: [
                //       Expanded(
                //         child: TextField(
                //           controller: linkControllers[index],
                //           decoration:
                //               InputDecoration(labelText: 'Link ${index + 1}'),
                //         ),
                //       ),
                //       IconButton(
                //         icon: const Icon(Icons.delete, color: Colors.red),
                //         onPressed: () => setState(() {
                //           linkControllers.removeAt(index);
                //           if (row['Links'].length > index) {
                //             row['Links'].removeAt(index);
                //           }
                //         }),
                //       ),
                //     ],
                //   );
                // }),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      int length = linkControllers.length;
                      print('TOTAL: $length');
                      // Add a new empty link controller
                      linkControllers.add(TextEditingController());
                      // Update maxLinks if necessary
                      length = linkControllers.length;
                      if (linkControllers.length > widget.maxLinks) {
                        print('TOTAL: $length');
                        widget.maxLinks = linkControllers.length;
                      }
                    });
                  },
                  // onPressed: () => setState(() {
                  //   linkControllers.add(TextEditingController());
                  // }),
                  child: const Text('Add Link'),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              row['PBN Name'] = pbnNameController.text;
              row['Category'] = categoryController.text;
              List<String> newLinks = linkControllers
                  .where((controller) => controller.text.isNotEmpty)
                  .map((controller) => controller.text)
                  .toList();
              print('new links $newLinks');
              List<String> oldLinks = row['Links'];
              print('old links $oldLinks');

              // Build the originalToNewLinks map for links that have changed
              for (int i = 0; i < row['Links'].length; i++) {
                String originalLink = row['Links'][i];
                print('new link: ${newLinks[i]}');
                print('original Link: $originalLink');
                if (i < newLinks.length && originalLink != newLinks[i]) {
                  originalToNewLinks[originalLink] = newLinks[i];
                }
              }

              row['Links'] = newLinks; // Directly update the row's links
              row['Total Links'] = newLinks.length;

              print('ORIGINAL LINKS: $originalToNewLinks');

              // Update all instances in excelData
              for (var dataRow in widget.excelData) {
                List<String> dataRowLinks = List.from(dataRow['Links']);
                bool updated = false;
                for (int i = 0; i < dataRowLinks.length; i++) {
                  String link = dataRowLinks[i];
                  if (originalToNewLinks.containsKey(link)) {
                    dataRowLinks[i] = originalToNewLinks[link]!;
                    updated = true;
                  }
                }
                if (updated) {
                  dataRow['Links'] = dataRowLinks;
                }
              }

              // Refresh filteredData based on the updated excelData
              _filterData();
            });

            Navigator.of(context).pop();
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Row(
        children: [
          TextButton(
            onPressed: () => _showEditDialog(context, index),
            child: Text('Edit', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(50, 30), // Set this size to fit your layout
            ),
          ),
          SizedBox(width: 8), // Space between buttons
          TextButton(
            onPressed: () => _showEditDialog(context, index),
            child: Text('Del', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(50, 30), // Set this size to fit your layout
            ),
          ),
        ],
      ),
      width: 150, // Adjust the width as needed
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  void _showFilterDialog(String column) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Set<String> options =
            widget.excelData.map((e) => e[column].toString()).toSet();
        Set<String> tempSelectedOptions = Set<String>();

        if (column == 'Category') {
          tempSelectedOptions.addAll(selectedCategories);
        } else if (column == 'Total Links') {
          tempSelectedOptions
              .addAll(selectedTotalLinks.map((e) => e.toString()));
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter $column'),
              content: SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    return CheckboxListTile(
                      title:
                          Text(option, style: TextStyle(color: Colors.white)),
                      value: tempSelectedOptions.contains(option),
                      onChanged: (bool? value) {
                        if (value == true) {
                          tempSelectedOptions.add(option);
                        } else {
                          tempSelectedOptions.remove(option);
                        }
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Apply'),
                  onPressed: () {
                    if (column == 'Category') {
                      selectedCategories = tempSelectedOptions;
                    } else if (column == 'Total Links') {
                      selectedTotalLinks = tempSelectedOptions;
                    }
                    // Reapply filters
                    _filterData();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    print(
        "filteredData length: ${filteredData.length}, accessing index: $index");
    // Correctly access rowData based on the current index.
    // 'filteredData' is already a list of maps, each representing a row.
    final rowData = filteredData[index]; // This line is correct

    List<Widget> rowWidgets = [
      Container(
        child: Text(
          rowData['PBN Name'] ?? '',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        width: 200,
        height: 52,
        alignment: Alignment.center,
      ),
      Container(
        child: Text(rowData['Category'] ?? '',
            style: TextStyle(color: Colors.white)),
        width: 150,
      ),
      Container(
        child: Text('${rowData['Total Links']}',
            style: TextStyle(color: Colors.white)),
        width: 150,
      ),
    ];

    List<String> links = rowData['Links'] ?? [];
    int linksCount = links.length; // Number of actual links available

// Ensure we do not attempt to access an index out of bounds
    rowWidgets.addAll(List<Widget>.generate(widget.maxLinks, (i) {
      if (i < linksCount) {
        return Container(
          child: Text(links[i], style: TextStyle(color: Colors.white)),
          width: 200,
        );
      } else {
        return Container(
          child: Text('N/A', style: TextStyle(color: Colors.white)),
          width: 200,
        );
      }
    }));

    return Row(children: rowWidgets);
  }
}
