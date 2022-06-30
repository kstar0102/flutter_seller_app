import 'dart:async';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Model/Attribute%20Models/AttributeValueModel/AttributeValue.dart';
import 'package:flutter/material.dart';

class InputChipUxScreen extends StatelessWidget {
  const InputChipUxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextButton(
                onPressed: () {
                  showModalBottomSheet<List<String>>(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    )),
                    enableDrag: true,
                    context: context,
                    builder: (context) {
                      return AddAttributeBottomSheet(
                        attributes: [],
                        selectedAttributeValues: [],
                      );
                    },
                  ).then((value) {});
                },
                child: Text(getTranslated(context, "Add Attribute")!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAttributeBottomSheet extends StatefulWidget {
  final List<AttributeValueModel> attributes;
  final List<AttributeValueModel> selectedAttributeValues;

  AddAttributeBottomSheet(
      {Key? key,
      required this.attributes,
      required this.selectedAttributeValues})
      : super(key: key);
  //  List<AttributeValueModel>
  @override
  _AddAttributeBottomSheetState createState() =>
      _AddAttributeBottomSheetState();
}

class _AddAttributeBottomSheetState extends State<AddAttributeBottomSheet> {
  //late StreamSubscription<bool> keyboardSubscription;
  // List<String> colors = ["Red", "Yellow", "Blue", "Green", "Pink", "Purple"];

  late List<AttributeValueModel> selectedAttribute =
      widget.selectedAttributeValues;

  List<AttributeValueModel> suggestedAttribute = [];

  bool showSuggestedAttributes = false;

  TextEditingController textEditingController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();

  @override
  void initState() {
    super.initState();
  }

  bool isAttributeAdded(String attributeid) {
    return selectedAttribute
        .where((element) => element.id == attributeid)
        .isNotEmpty;
  }

  Widget _buildSuggestions() {
    return Column(
      children: suggestedAttribute
          .map((e) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: isAttributeAdded(e.id!) ? grey : Colors.white,
                  onTap: () {
                    if (isAttributeAdded(e.id!)) {
                      selectedAttribute.remove(e);
                    } else {
                      selectedAttribute.add(e);
                    }
                    setState(() {});
                  },
                  title: Text(
                    e.value!,
                    style: TextStyle(color: primary),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSelectedAttributes() {
    return selectedAttribute.isEmpty
        ? Center(
            child: Text(
              getTranslated(context, "Please add attributes")!,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )
        : Column(
            children: selectedAttribute
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        tileColor: isAttributeAdded(e.id!)
                            ? Colors.grey
                            : Colors.white,
                        onTap: () {
                          selectedAttribute.remove(e);
                          setState(() {});
                        },
                        title: Text(e.value!),
                      ),
                    ))
                .toList(),
          );
  }

  void clearTextField() {
    textEditingController.clear();
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      showSuggestedAttributes = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusNode? searchattributeFocus = FocusNode();
    return WillPopScope(
      onWillPop: () {
        if (textEditingController.text.isNotEmpty) {
          clearTextField();
          return Future.value(false);
        }
        Navigator.of(context).pop(selectedAttribute);
        return Future.value(false);
      },
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.text,
                  focusNode: searchattributeFocus,
                  style: TextStyle(
                    color: fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  onTap: () {
                    setState(() {
                      showSuggestedAttributes = true;
                      suggestedAttribute.clear();
                    });
                  },
                  controller: textEditingController,
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      final suggestions = widget.attributes
                          .where((element) => element.value!
                              .toLowerCase()
                              .contains(value.trim().toLowerCase()))
                          .toList();

                      suggestedAttribute.clear();
                      suggestedAttribute.addAll(suggestions);
                      if (!showSuggestedAttributes) {
                        showSuggestedAttributes = true;
                      }

                      setState(() {});
                    } else {
                      //
                      showSuggestedAttributes = false;
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    prefixIcon: IconButton(
                        color: red,
                        iconSize: 30,
                        onPressed: () {
                          clearTextField();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close)),
                    // suffixIcon: IconButton(
                    //   color: Colors.green,
                    //   iconSize: 30,
                    //   onPressed: () {
                    //     Navigator.of(context).pop();
                    //   },
                    //   icon: Icons(Icons.done),
                    // ),
                    hintText: "Search Attribute",
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: lightBlack,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                AnimatedSwitcher(
                    duration: Duration(
                      milliseconds: 300,
                    ),
                    child: showSuggestedAttributes
                        ? _buildSuggestions()
                        : _buildSelectedAttributes()),
                SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (0.85),
          ),
        ),
      ),
    );
  }
}
