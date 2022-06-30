import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';

class ProductDescription extends StatefulWidget {
  //ProductDescription({Key? key},) : super(key: key);
  String? description;

  ProductDescription(this.description);

  @override
  _ProductDescriptionState createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  String result = '';
  bool isLoading = true;
  final HtmlEditorController controller = HtmlEditorController();

  @override
  void initState() {
    setValue();
    // print("description 11: ${widget.description!}");
    // controller.setText(widget.description!);

    super.initState();
  }

  setValue() async {
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        isLoading = false;
      });
    });

    Future.delayed(const Duration(seconds: 6), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.setText(widget.description!);
    var temp = controller.getText();
    print("temp = $temp");
    print("this line executed now data is ${controller.getText().toString()}");

    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus(); // for close keybord
        }
      },
      child: Scaffold(
        appBar: getAppBar("Product Description", context),
        backgroundColor: white,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: white,
              onPressed: () {
                controller.editorController!.reload();
              },
              child: Text(
                "Clear",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: primary,
                ),
              ),
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              backgroundColor: white,
              onPressed: () {
                Navigator.of(context).pop(result);
                print("result : $result");
              },
              child: Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? shimmer()
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    HtmlEditor(
                      controller: controller,
                      htmlEditorOptions: HtmlEditorOptions(
                        hint: 'Please Enter Product Description here...!',
                        shouldEnsureVisible: true,
                      ),
                      htmlToolbarOptions: HtmlToolbarOptions(
                        toolbarPosition: ToolbarPosition.aboveEditor,
                        toolbarType: ToolbarType.nativeGrid, //by default
                        gridViewHorizontalSpacing: 0,
                        gridViewVerticalSpacing: 0,
                        dropdownBackgroundColor: lightWhite,
                        toolbarItemHeight: 40,
                        buttonColor: fontColor,
                        buttonFocusColor: primary,
                        buttonBorderColor: Colors.red,
                        buttonFillColor: secondary,
                        dropdownIconColor: primary,
                        dropdownIconSize: 26,
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: pink,
                        ),
                        onButtonPressed: (ButtonType type, bool? status,
                            Function()? updateStatus) {
                          return true;
                        },
                        onDropdownChanged: (DropdownType type, dynamic changed,
                            Function(dynamic)? updateSelectedItem) {
                          return true;
                        },
                        mediaLinkInsertInterceptor:
                            (String url, InsertFileType type) {
                          return true;
                        },
                        mediaUploadInterceptor:
                            (PlatformFile file, InsertFileType type) async {
                          return true;
                        },
                      ),
                      otherOptions: OtherOptions(
                        height: height * 0.85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: lightWhite,
                        ),
                      ),
                      callbacks: Callbacks(
                          onBeforeCommand: (String? currentHtml) {},
                          onChangeContent: (String? changed) {},
                          onChangeCodeview: (String? changed) {
                            result = changed!;
                          },
                          onChangeSelection: (EditorSettings settings) {},
                          onDialogShown: () {},
                          onEnter: () {},
                          onFocus: () {},
                          onBlur: () {},
                          onBlurCodeview: () {},
                          onInit: () {},
                          onImageUploadError: (
                            FileUpload? file,
                            String? base64Str,
                            UploadError error,
                          ) {},
                          onKeyDown: (int? keyCode) {},
                          onKeyUp: (int? keyCode) {},
                          onMouseDown: () {},
                          onMouseUp: () {},
                          onNavigationRequestMobile: (String url) {
                            return NavigationActionPolicy.ALLOW;
                          },
                          onPaste: () {},
                          onScroll: () {}),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       TextButton(
                    //         style: TextButton.styleFrom(
                    //             backgroundColor: Theme.of(context).accentColor),
                    //         onPressed: () async {
                    //           var txt = await controller.getText();
                    //           print("text");
                    //           print(txt);
                    //           if (txt.contains('src=\"data:')) {
                    //             txt =
                    //                 '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                    //           }
                    //           setState(() {
                    //             result = txt;
                    //           });
                    //         },
                    //         child: Text(
                    //           'Submit',
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}
