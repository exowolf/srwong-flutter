import 'package:flutter/material.dart';
import 'package:flutter_pdg/data/model/body/review_body_model.dart';
import 'package:flutter_pdg/data/model/response/order_model.dart';
import 'package:flutter_pdg/helper/responsive_helper.dart';
import 'package:flutter_pdg/localization/language_constrants.dart';
import 'package:flutter_pdg/provider/product_provider.dart';
import 'package:flutter_pdg/provider/theme_provider.dart';
import 'package:flutter_pdg/utill/color_resources.dart';
import 'package:flutter_pdg/utill/dimensions.dart';
import 'package:flutter_pdg/utill/styles.dart';
import 'package:flutter_pdg/view/base/custom_button.dart';
import 'package:flutter_pdg/view/base/custom_snackbar.dart';
import 'package:flutter_pdg/view/base/custom_text_field.dart';
import 'package:flutter_pdg/view/base/footer_view.dart';
import 'package:flutter_pdg/view/screens/track/widget/delivery_man_widget.dart';
import 'package:provider/provider.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan deliveryMan;
  final String orderID;
  DeliveryManReviewWidget({@required this.deliveryMan, @required this.orderID});

  @override
  _DeliveryManReviewWidgetState createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                    child: SizedBox(
                      width: 1170,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        widget.deliveryMan != null ? DeliveryManWidget(deliveryMan: widget.deliveryMan) : SizedBox(),
                        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                        Container(
                          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                              color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 300],
                              blurRadius: 5, spreadRadius: 1,
                            )],
                          ),
                          child: Column(children: [
                            Text(
                              getTranslated('rate_his_service', context),
                              style: rubikMedium.copyWith(color: ColorResources.getGreyBunkerColor(context)), overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            SizedBox(
                              height: 30,
                              child: ListView.builder(
                                itemCount: 5,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    child: Icon(
                                      productProvider.deliveryManRating < (i + 1) ? Icons.star_border : Icons.star,
                                      size: 25,
                                      color: productProvider.deliveryManRating < (i + 1)
                                          ? ColorResources.getGreyColor(context)
                                          : Theme.of(context).primaryColor,
                                    ),
                                    onTap: () {
                                      Provider.of<ProductProvider>(context, listen: false).setDeliveryManRating(i + 1);
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            Text(
                              getTranslated('share_your_opinion', context),
                              style: rubikMedium.copyWith(color: ColorResources.getGreyBunkerColor(context)), overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                            CustomTextField(
                              maxLines: 5,
                              capitalization: TextCapitalization.sentences,
                              controller: _controller,
                              hintText: getTranslated('write_your_review_here', context),
                              fillColor: ColorResources.getSearchBg(context),
                            ),
                            SizedBox(height: 40),

                            // Submit button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
                              child: Column(
                                children: [
                                  !productProvider.isLoading ? CustomButton(
                                    btnTxt: getTranslated('submit', context),
                                    onTap: () {
                                      if (productProvider.deliveryManRating == 0) {
                                        showCustomSnackBar('Give a rating', context);
                                      } else if (_controller.text.isEmpty) {
                                        showCustomSnackBar('Write a review', context);
                                      } else {
                                        FocusScopeNode currentFocus = FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        ReviewBody reviewBody = ReviewBody(
                                          deliveryManId: widget.deliveryMan.id.toString(),
                                          rating: productProvider.deliveryManRating.toString(),
                                          comment: _controller.text,
                                          orderId: widget.orderID,
                                        );
                                        productProvider.submitDeliveryManReview(reviewBody).then((value) {
                                          if (value.isSuccess) {
                                            showCustomSnackBar(value.message, context, isError: false);
                                            _controller.text = '';
                                          } else {
                                            showCustomSnackBar(value.message, context);
                                          }
                                        });
                                      }
                                    },
                                  ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                                ],
                              ),
                            ),
                          ]),
                        ),

                      ]),
                    ),
                  ),
                ),

                if(ResponsiveHelper.isDesktop(context)) Padding(
                  padding: const EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
                  child: FooterView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
