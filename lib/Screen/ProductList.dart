import 'dart:async';
import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Constant.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/SimBtn.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:eshopmultivendor/Model/ProductModel/Product.dart';
import 'package:eshopmultivendor/Screen/EditProduct.dart';
import 'package:flutter/material.dart';
import 'Add_Product.dart';
import 'Search.dart';

class ProductList extends StatefulWidget {
  final String? flag;

  const ProductList({Key? key, this.flag}) : super(key: key);
  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String? sortBy = 'p.id', orderBy = "DESC", flag = ' ';
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();
  List<dynamic>? filterList = [];
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  String? filter = "";

  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  List<TextEditingController> _controller = [];
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  var items;

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    flag = widget.flag;
    getProduct("0");

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: width * 0.7,
      end: 50.0,
    ).animate(
      new CurvedAnimation(
        parent: buttonController!,
        curve: new Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    controller.removeListener(() {});
    for (int i = 0; i < _controller.length; i++) _controller[i].dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: lightWhite,
      appBar: getAppbar(),
      floatingActionButton: floatingBtn(),
      key: _scaffoldKey,
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : productList.length == 0
                  ? getNoItem(context)
                  : Stack(
                      children: <Widget>[
                        _showForm(),
                        showCircularProgress(_isProgress, primary),
                      ],
                    )
          : noInternet(context),
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, "NO_INTERNET")!,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();
              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  offset = 0;
                  total = 0;
                  flag = '';
                  getProduct("0");
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  noIntBtn(BuildContext context) {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0)),
          ),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => super.widget));
          },
          child: Ink(
            child: Container(
              constraints: BoxConstraints(maxWidth: width / 1.2, minHeight: 45),
              alignment: Alignment.center,
              child: Text(getTranslated(context, "NO_INTERNET")!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: white, fontWeight: FontWeight.normal)),
            ),
          ),
        )));
  }

  Widget listItem(int index) {
    if (index < productList.length) {
      Product? model = productList[index];
      totalProduct = model.total;

      String stockType = "";
      if (model.stockType == "null")
        stockType = "Not enabled";
      else if (model.stockType == "1" || model.stockType == "0")
        stockType = "Global";
      else if (model.stockType == "2") stockType = "Varient wise";

      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;
      items = new List<String>.generate(
          model.totalAllow != "" ? int.parse(model.totalAllow!) : 10,
          (i) => (i + 1).toString());

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      return Card(
        elevation: 0,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  model: model,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: "$index${model.id}+ $index${model.name}",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: FadeInImage(
                          image: NetworkImage(model.image!),
                          height: 80.0,
                          width: 80.0,
                          // fit: extendImg ? BoxFit.fill : BoxFit.contain,
                          placeholder: placeHolder(80),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              model.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(color: lightBlack),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                    CUR_CURRENCY + " " + price.toString() + " ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? CUR_CURRENCY +
                                          "" +
                                          model
                                              .prVarientList![model.selVarient!]
                                              .price!
                                      : "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0),
                                ),
                              ],
                            ),
                            Text(
                              getTranslated(context, "StockType")! +
                                  ': $stockType',
                            ),
                            model.stockType != "null"
                                ? Text(
                                    getTranslated(context, "StockCount")! +
                                        ': ${model.prVarientList![model.selVarient!].stock ?? ''}',
                                    style: TextStyle(
                                        color: fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    ProductDeletDialog(model.name!, model.id!);
                                  },
                                  child: Card(
                                    child: Icon(
                                      Icons.delete,
                                      color: primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                model.type == "variable_product"
                                    ? Align(
                                        alignment: Alignment.bottomRight,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Product model = productList[index];
                                            _chooseVarient(model);
                                          },
                                          child: Text(getTranslated(
                                              context, "SelectVarient")!),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              model.availability == "0"
                  ? Text(getTranslated(context, "OutOfStock")!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: red, fontWeight: FontWeight.bold))
                  : Container(),
            ],
          ),
        ),
      );
    } else
      return Container();
  }

  updateProductList() {
    if (mounted) setState(() {});
  }

//==============================================================================
//=============================== floating Button ==============================

  floatingBtn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          backgroundColor: white,
          child: Icon(
            Icons.add,
            size: 32,
            color: fontColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<String>(
                builder: (context) => AddProduct(),
              ),
            );
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Future<Null> getProduct(String top) async {
    if (readProduct) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        var parameter = {
          //CATID: widget.id ?? '',
          SellerId: CUR_USERID,
          SORT: sortBy,
          Order: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          TOP_RETAED: top,
          FLAG: flag
        };
        if (selId != null && selId != "") {
          parameter[AttributeValueIds] = selId;
        }
        apiBaseHelper.postAPICall(getProductsApi, parameter).then(
          (getdata) async {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              total = int.parse(getdata["total"]);

              if (_isFirstLoad) {
                filterList = getdata["filters"];
                _isFirstLoad = false;
              }

              if ((offset) < total) {
                tempList.clear();

                var data = getdata["data"];
                tempList = (data as List)
                    .map((data) => new Product.fromJson(data))
                    .toList();
                getAvailVarient();

                offset = offset + perPage;
              }
            } else {
              if (msg != "Products Not Found !") setSnackbar(msg!);
              isLoadingmore = false;
            }
            if (mounted)
              setState(() {
                _isLoading = false;
              });
          },
          onError: (error) {
            setSnackbar(error.toString());
            if (mounted)
              setState(
                () {
                  _isLoading = false;
                  isLoadingmore = false;
                },
              );
          },
        );
      } else {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      Future.delayed(Duration(microseconds: 500)).then((_) async {
        setSnackbar('You have not authorized permission for read Product!!');
      });
    }
    return null;
  }

  void getAvailVarient() {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;
            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  getAppbar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: white,
      iconTheme: IconThemeData(color: primary),
      title: Text(
        getTranslated(context, "Products")!,
        style: TextStyle(
          color: grad2Color,
        ),
      ),
      elevation: 5,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: shadow(),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: primary,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              stockFilter();
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.filter_alt_outlined,
                color: primary,
                size: 25,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Search(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.search,
                color: primary,
                size: 25,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  listType ? Icons.grid_view : Icons.list,
                  color: primary,
                  size: 25,
                ),
              ),
              onTap: () {
                productList.length != 0
                    ? setState(() {
                        listType = !listType;
                      })
                    : null;
              },
            ),
          ),
        ),
        Container(
          width: 40,
          margin: EdgeInsetsDirectional.only(top: 10, bottom: 10, end: 5),
          child: Material(
            color: Colors.transparent,
            child: PopupMenuButton(
              padding: EdgeInsets.zero,
              onSelected: (dynamic value) {
                switch (value) {
                  case 0:
                    return filterDialog();
                    break;
                  case 1:
                    return sortDialog();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem(
                  value: 0,
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                    leading: Icon(
                      Icons.tune,
                      color: fontColor,
                      size: 25,
                    ),
                    title: Text(getTranslated(context, "Filter")!),
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                    leading: Icon(Icons.sort, color: fontColor, size: 20),
                    title: Text(getTranslated(context, "Sort")!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget productItem(int index, bool pad) {
    if (index < productList.length) {
      Product model = productList[index];

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }
      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;
      items = new List<String>.generate(
          model.totalAllow != "" ? int.parse(model.totalAllow!) : 10,
          (i) => (i + 1).toString());

      String stockType = "";
      if (model.stockType == "null")
        stockType = "Not enabled";
      else if (model.stockType == "1" || model.stockType == "0")
        stockType = "Global";
      else if (model.stockType == "2") stockType = "Varient wise";

      double width1 = width * 0.5;

      return Card(
        elevation: 0.2,
        margin: EdgeInsetsDirectional.only(bottom: 5, end: pad ? 5 : 0),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  model: model,
                ),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag: "$index${model.id} 55",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: NetworkImage(model.image!),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          // fit: extendImg ? BoxFit.fill : BoxFit.contain,
                          placeholder: placeHolder(width),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: model.availability == "0"
                          ? Text(
                              getTranslated(context, "OutOfStock")!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    color: red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 5.0, top: 5, bottom: 5),
                child: Text(
                  model.name!,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(" " + CUR_CURRENCY + " " + price.toString() + " ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  double.parse(model
                              .prVarientList![model.selVarient!].disPrice!) !=
                          0
                      ? Flexible(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? CUR_CURRENCY +
                                          "" +
                                          model
                                              .prVarientList![model.selVarient!]
                                              .price!
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  InkWell(
                    onTap: () {
                      ProductDeletDialog(model.name!, model.id!);
                    },
                    child: Card(
                      child: Icon(
                        Icons.delete,
                        color: primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  getTranslated(context, "StockType")! + ': $stockType',
                ),
              ),
              model.stockType != "null"
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        getTranslated(context, "StockCount")! +
                            ': ${model.prVarientList![model.selVarient!].stock ?? ''}',
                        style: TextStyle(
                            color: fontColor, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Container(),
              model.type == "variable_product"
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Product model = productList[index];
                            _chooseVarient(model);
                          },
                          child: Text(getTranslated(context, "SelectVarient")!),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    } else
      return Container();
  }

  void _chooseVarient(Product model) {
    bool? available, outOfStock;
    int? selectIndex = 0;
    List<int?> _selectedIndex = [];
    ChoiceChip choiceChip;
    int? _oldSelVarient = 0;
    //selList--selected list
    //sinList---single attribute list for compare
    _selectedIndex.clear();
    if (model.stockType == "0" || model.stockType == "1") {
      if (model.availability == "1") {
        available = true;
        outOfStock = false;
        _oldSelVarient = model.selVarient;
      } else {
        available = false;
        outOfStock = true;
      }
    } else if (model.stockType == "") {
      available = true;
      outOfStock = false;
      _oldSelVarient = model.selVarient;
    } else if (model.stockType == "2") {
      if (model.prVarientList![model.selVarient!].availability == "1") {
        available = true;
        outOfStock = false;
        _oldSelVarient = model.selVarient;
      } else {
        available = false;
        outOfStock = true;
      }
    }

    List<String> selList =
        model.prVarientList![model.selVarient!].attribute_value_ids!.split(",");

    for (int i = 0; i < model.attributeList!.length; i++) {
      List<String> sinList = model.attributeList![i].id!.split(',');

      for (int j = 0; j < sinList.length; j++) {
        if (selList.contains(sinList[j])) {
          _selectedIndex.insert(i, j);
        }
      }

      if (_selectedIndex.length == i) _selectedIndex.insert(i, null);
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      getTranslated(context, "SelectVarient")!,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Divider(),
                  _title(model.name!),
                  available! || outOfStock!
                      ? _price(model.prVarientList![_oldSelVarient!].disPrice!,
                          model.prVarientList![_oldSelVarient!].price)
                      : Container(),
                  available! || outOfStock!
                      ? _offPrice(
                          model.prVarientList![_oldSelVarient!].disPrice!,
                          model.prVarientList![_oldSelVarient!].price)
                      : Container(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: model.attributeList!.length,
                    itemBuilder: (context, index) {
                      List<Widget> chips = [];
                      List<String> att =
                          model.attributeList![index].value!.split(',');
                      List<String> attId =
                          model.attributeList![index].id!.split(',');
                      List<String> attSType =
                          model.attributeList![index].sType!.split(',');

                      List<String> attSValue =
                          model.attributeList![index].sValue!.split(',');

                      int? varSelected;

                      List<String> wholeAtt = model.attrIds!.split(',');
                      for (int i = 0; i < att.length; i++) {
                        Widget itemLabel;
                        if (attSType[i] == "1") {
                          String clr = (attSValue[i].substring(1));

                          String color = "0xff" + clr;

                          itemLabel = Container(
                            width: 25,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(int.parse(color))),
                          );
                        } else if (attSType[i] == "2") {
                          itemLabel = ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(attSValue[i],
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) =>
                                      erroWidget(80)));
                        } else {
                          itemLabel = Text(att[i],
                              style: TextStyle(
                                  color: _selectedIndex[index] == (i)
                                      ? fontColor
                                      : white));
                        }

                        if (_selectedIndex[index] != null) if (wholeAtt
                            .contains(attId[i])) {
                          choiceChip = ChoiceChip(
                            selected: _selectedIndex.length > index
                                ? _selectedIndex[index] == i
                                : false,
                            label: itemLabel,
                            labelPadding: EdgeInsets.all(0),
                            selectedColor: fontColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  attSType[i] == "1" ? 100 : 10),
                              side: BorderSide(
                                  color: _selectedIndex[index] == (i)
                                      ? fontColor
                                      : black12,
                                  width: 1.5),
                            ),
                            onSelected: att.length == 1
                                ? null
                                : (bool selected) {
                                    if (selected) if (mounted)
                                      setState(() {
                                        available = false;
                                        _selectedIndex[index] =
                                            selected ? i : null;
                                        List<int> selectedId =
                                            []; //list where user choosen item id is stored
                                        List<bool> check = [];
                                        for (int i = 0;
                                            i < model.attributeList!.length;
                                            i++) {
                                          List<String> attId = model
                                              .attributeList![i].id!
                                              .split(',');

                                          if (_selectedIndex[i] != null)
                                            selectedId.add(int.parse(
                                                attId[_selectedIndex[i]!]));
                                        }
                                        check.clear();
                                        late List<String> sinId;
                                        findMatch:
                                        for (int i = 0;
                                            i < model.prVarientList!.length;
                                            i++) {
                                          sinId = model.prVarientList![i]
                                              .attribute_value_ids!
                                              .split(",");

                                          for (int j = 0;
                                              j < selectedId.length;
                                              j++) {
                                            if (sinId.contains(
                                                selectedId[j].toString())) {
                                              check.add(true);

                                              if (selectedId.length ==
                                                      sinId.length &&
                                                  check.length ==
                                                      selectedId.length) {
                                                varSelected = i;
                                                selectIndex = i;
                                                break findMatch;
                                              }
                                            } else {
                                              check.clear();
                                              selectIndex = null;
                                              break;
                                            }
                                          }
                                        }

                                        if (selectedId.length == sinId.length &&
                                            check.length == selectedId.length) {
                                          if (model.stockType == "0" ||
                                              model.stockType == "1") {
                                            if (model.availability == "1") {
                                              available = true;
                                              outOfStock = false;
                                              _oldSelVarient = varSelected;
                                            } else {
                                              available = false;
                                              outOfStock = true;
                                            }
                                          } else if (model.stockType ==
                                              "null") {
                                            available = true;
                                            outOfStock = false;
                                            _oldSelVarient = varSelected;
                                          } else if (model.stockType == "2") {
                                            if (model
                                                    .prVarientList![
                                                        varSelected!]
                                                    .availability ==
                                                "1") {
                                              available = true;
                                              outOfStock = false;
                                              _oldSelVarient = varSelected;
                                            } else {
                                              available = false;
                                              outOfStock = true;
                                            }
                                          }
                                        } else {
                                          available = false;
                                          outOfStock = false;
                                        }
                                      });
                                  },
                          );

                          chips.add(choiceChip);
                        }
                      }

                      String value = _selectedIndex[index] != null &&
                              _selectedIndex[index]! <= att.length
                          ? att[_selectedIndex[index]!]
                          : ' Please Select';

                      return chips.length > 0
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    model.attributeList![index].name! +
                                        " : " +
                                        value,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  new Wrap(
                                    children: chips.map<Widget>((Widget chip) {
                                      return Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: chip,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            )
                          : Container();
                    },
                  ),
                  available == false || outOfStock == true
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            outOfStock == true
                                ? getTranslated(context, "OutOfStock")!
                                : getTranslated(
                                    context, "Thisvarientnotavailable")!,
                            style: TextStyle(color: red),
                          ),
                        ))
                      : Container(),
                ],
              ),
            );
          });
        });
  }

  _price(String disPrice, String? price1) {
    double price = double.parse(disPrice);
    if (price == 0) price = double.parse(price1!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(CUR_CURRENCY + " " + price.toString(),
          style: Theme.of(context).textTheme.headline6),
    );
  }

  _offPrice(String disPrice, String? price1) {
    double price = double.parse(disPrice);

    if (price != 0) {
      double off = (double.parse(price1!) - double.parse(disPrice)).toDouble();
      off = off * 100 / double.parse(price1);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Text(
              CUR_CURRENCY + " " + price1,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  decoration: TextDecoration.lineThrough, letterSpacing: 0),
            ),
            Text(" | " + off.toStringAsFixed(2) + "% off",
                style: Theme.of(context)
                    .textTheme
                    .overline!
                    .copyWith(color: primary, letterSpacing: 0)),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  _title(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Text(
        name,
        style:
            Theme.of(context).textTheme.subtitle1!.copyWith(color: lightBlack),
      ),
    );
  }

  void stockFilter() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: new AlertDialog(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          getTranslated(context, "StockFilter")!,
                          style: Theme.of(context).textTheme.headline6,
                        )),
                    Divider(color: lightBlack),
                    TextButton(
                        child: Text(getTranslated(context, "All")!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: lightBlack)),
                        onPressed: () {
                          flag = '';
                          if (mounted)
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            });
                          getProduct("0");
                          Navigator.pop(context, 'option 1');
                        }),
                    Divider(color: lightBlack),
                    TextButton(
                        child: Text(getTranslated(context, "Soldout")!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: lightBlack)),
                        onPressed: () {
                          flag = 'sold';
                          if (mounted)
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            });
                          getProduct("0");
                          Navigator.pop(context, 'option 1');
                        }),
                    Divider(color: lightBlack),
                    TextButton(
                        child: Text(
                          getTranslated(context, "Lowinstock")!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack),
                        ),
                        onPressed: () {
                          flag = 'low';
                          if (mounted)
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            });
                          getProduct("0");
                          Navigator.pop(context, 'option 2');
                        }),
                    Divider(color: white),
                  ]),
                )),
          );
        });
  }

  void sortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ButtonBarTheme(
          data: ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          ),
          child: new AlertDialog(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            contentPadding: const EdgeInsets.all(0.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding:
                          EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                      child: Text(
                        getTranslated(context, "SortBy")!,
                        style: Theme.of(context).textTheme.headline6,
                      )),
                  Divider(color: lightBlack),
                  TextButton(
                      child: Text(getTranslated(context, "TopRated")!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        sortBy = '';
                        orderBy = 'DESC';
                        flag = '';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("1");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: lightBlack),
                  TextButton(
                      child: Text(getTranslated(context, "NewestFirst")!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'DESC';
                        flag = '';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: lightBlack),
                  TextButton(
                      child: Text(
                        getTranslated(context, "OldestFirst")!,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'ASC';
                        flag = '';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0");
                        Navigator.pop(context, 'option 2');
                      }),
                  Divider(color: lightBlack),
                  TextButton(
                      child: new Text(
                        getTranslated(context, "LOWTOHIGH")!,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'pv.price';
                        orderBy = 'ASC';
                        flag = '';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0");
                        Navigator.pop(context, 'option 3');
                      }),
                  Divider(color: lightBlack),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 5.0),
                    child: TextButton(
                      child: new Text(
                        getTranslated(context, "HIGHTOLOW")!,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'pv.price';
                        orderBy = 'DESC';
                        flag = '';
                        if (mounted)
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        getProduct("0");
                        Navigator.pop(context, 'option 4');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(
            () {
              isLoadingmore = true;

              if (offset < total) getProduct("0");
            },
          );
      }
    }
  }

  Future<Null> _refresh() {
    if (mounted)
      setState(() {
        _isLoading = true;
        isLoadingmore = true;
        offset = 0;
        total = 0;
        productList.clear();
      });
    return getProduct("0");
  }

  _showForm() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: listType
          ? ListView.builder(
              controller: controller,
              itemCount: (offset < total)
                  ? productList.length + 1
                  : productList.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (index == productList.length && isLoadingmore)
                    ? Center(child: CircularProgressIndicator())
                    : listItem(index);
              },
            )
          : GridView.count(
              padding: EdgeInsetsDirectional.only(top: 5),
              crossAxisCount: 2,
              controller: controller,
              childAspectRatio: 0.8,
              physics: AlwaysScrollableScrollPhysics(),
              children: List.generate(
                (offset < total) ? productList.length + 1 : productList.length,
                (index) {
                  return (index == productList.length && isLoadingmore)
                      ? Center(child: CircularProgressIndicator())
                      : productItem(index, index % 2 == 0 ? true : false);
                },
              ),
            ),
    );
  }

  ProductDeletDialog(String productName, String id) async {
    String pName = productName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Text(
                getTranslated(context, "sure")! +
                    " \"  $pName \" " +
                    getTranslated(context, "PRODUCT")!,
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                new TextButton(
                    child: Text(
                      getTranslated(context, "LOGOUTNO")!,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                new TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTYES")!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // setSnackbar("Not Able To Delete Product in Demo APK");
                    Navigator.pop(context);
                    delProductApi(id);

                    setState(
                      () {
                        _isLoading = true;
                        isLoadingmore = true;
                        offset = 0;
                        total = 0;
                        productList.clear();
                        getProduct("0");
                      },
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  delProductApi(String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {
        ProductId: id,
      };
      apiBaseHelper.postAPICall(getDeleteProductApi, parameter).then(
        (getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            setSnackbar(msg!);
          } else {
            setSnackbar(msg!);
          }
        },
        onError: (error) {
          print(error);
        },
      );
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
    }
    return null;
  }

  void filterDialog() {
    if (filterList!.length > 0)
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                  padding: const EdgeInsetsDirectional.only(top: 30.0),
                  child: AppBar(
                    backgroundColor: lightWhite,
                    title: Text(
                      getTranslated(context, "Filter")!,
                      style: TextStyle(
                        color: fontColor,
                      ),
                    ),
                    elevation: 5,
                    leading: Builder(builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.all(10),
                        decoration: shadow(),
                        child: Card(
                          elevation: 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 4.0),
                              child: Icon(Icons.keyboard_arrow_left,
                                  color: primary),
                            ),
                          ),
                        ),
                      );
                    }),
                    actions: [
                      Container(
                        margin: EdgeInsetsDirectional.only(end: 10.0),
                        alignment: Alignment.center,
                        child: InkWell(
                            child: Text(getTranslated(context, "ClearFilters")!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: fontColor)),
                            onTap: () {
                              if (mounted)
                                setState(() {
                                  selectedId.clear();
                                });
                            }),
                      ),
                    ],
                  )),
              Expanded(
                  child: Container(
                      color: lightWhite,
                      padding: EdgeInsetsDirectional.only(
                          start: 7.0, end: 7.0, top: 7.0),
                      child: Card(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Expanded(
                                flex: 2,
                                child: Container(
                                    color: lightWhite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      padding:
                                          EdgeInsetsDirectional.only(top: 10.0),
                                      itemCount: filterList!.length,
                                      itemBuilder: (context, index) {
                                        attsubList = filterList![index]
                                                ['attribute_values']
                                            .split(',');

                                        attListId = filterList![index]
                                                ['attribute_values_id']
                                            .split(',');

                                        if (filter == "") {
                                          filter = filterList![0]["name"];
                                        }

                                        return InkWell(
                                            onTap: () {
                                              if (mounted)
                                                setState(() {
                                                  filter = filterList![index]
                                                      ['name'];
                                                });
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: 20,
                                                      top: 10.0,
                                                      bottom: 10.0),
                                              decoration: BoxDecoration(
                                                  color: filter ==
                                                          filterList![index]
                                                              ['name']
                                                      ? white
                                                      : lightWhite,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  7),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  7))),
                                              alignment: Alignment.centerLeft,
                                              child: new Text(
                                                filterList![index]['name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!
                                                    .copyWith(
                                                        color: filter ==
                                                                filterList![
                                                                        index]
                                                                    ['name']
                                                            ? fontColor
                                                            : lightBlack,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ));
                                      },
                                    ))),
                            Expanded(
                                flex: 3,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    padding:
                                        EdgeInsetsDirectional.only(top: 10.0),
                                    scrollDirection: Axis.vertical,
                                    itemCount: filterList!.length,
                                    itemBuilder: (context, index) {
                                      if (filter ==
                                          filterList![index]["name"]) {
                                        attsubList = filterList![index]
                                                ['attribute_values']
                                            .split(',');

                                        attListId = filterList![index]
                                                ['attribute_values_id']
                                            .split(',');
                                        return Container(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount: attListId!.length,
                                                itemBuilder: (context, i) {
                                                  return CheckboxListTile(
                                                    dense: true,
                                                    title: Text(attsubList![i],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1!
                                                            .copyWith(
                                                                color:
                                                                    lightBlack,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                    value: selectedId.contains(
                                                        attListId![i]),
                                                    activeColor: primary,
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    onChanged: (bool? val) {
                                                      if (mounted)
                                                        setState(() {
                                                          if (val == true) {
                                                            selectedId.add(
                                                                attListId![i]);
                                                          } else {
                                                            selectedId.remove(
                                                                attListId![i]);
                                                          }
                                                        });
                                                    },
                                                  );
                                                }));
                                      } else {
                                        return Container();
                                      }
                                    })),
                          ])))),
              Container(
                color: white,
                child: Row(children: <Widget>[
                  Padding(
                      padding: EdgeInsetsDirectional.only(start: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(total.toString()),
                          Text(getTranslated(context, "Productsfound")!),
                        ],
                      )),
                  Spacer(),
                  SimBtn(
                      size: 0.4,
                      title: getTranslated(context, "Apply")!,
                      onBtnSelected: () {
                        if (selectedId != null) {
                          selId = selectedId.join(',');
                        }

                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0");
                        Navigator.pop(context, 'Product Filter');
                      }),
                ]),
              )
            ]);
          });
        },
      );
  }
}
