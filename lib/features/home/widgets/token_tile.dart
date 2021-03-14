import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusecash/redux/viewsmodels/token_tile.dart';
import 'package:fusecash/widgets/default_logo.dart';
import 'package:flutter/material.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/models/tokens/token.dart';
import 'package:fusecash/utils/format.dart';

class TokenTile extends StatelessWidget {
  TokenTile({
    Key key,
    this.token,
    this.showPending = true,
    this.onTap,
    this.quate,
    this.symbolHeight = 60.0,
    this.symbolWidth = 60.0,
  }) : super(key: key);
  final Function() onTap;
  final double quate;
  final bool showPending;
  final double symbolWidth;
  final double symbolHeight;
  final Token token;
  @override
  Widget build(BuildContext context) {
    final String price = token.priceInfo != null
        ? reduce(double.parse(token?.priceInfo?.total))
        : '0';
    // final bool isFuseTxs = token.originNetwork != null;
    return Container(
      child: ListTile(
        onTap: onTap != null ? onTap : null,
        // : () {
        //     ExtendedNavigator.of(context)
        //         .pushTokenScreen(tokenAddress: token.address);
        //   },
        contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 8,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  StoreConnector<AppState, TokenTileViewModel>(
                    distinct: true,
                    converter: TokenTileViewModel.fromStore,
                    builder: (_, viewModel) {
                      final bool isCommunityToken = viewModel.communities.any(
                          (element) =>
                              element?.homeTokenAddress?.toLowerCase() !=
                                  null &&
                              element?.homeTokenAddress?.toLowerCase() ==
                                  token?.address &&
                              ![false, null]
                                  .contains(element.metadata.isDefaultImage));
                      return Flexible(
                        flex: 4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: token.imageUrl != null &&
                                      token.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      width: symbolWidth,
                                      height: symbolHeight,
                                      imageUrl: token.imageUrl,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.error,
                                        size: 54,
                                      ),
                                    )
                                  : DefaultLogo(
                                      symbol: token?.symbol,
                                      width: symbolWidth,
                                      height: symbolHeight,
                                    ),
                            ),
                            showPending &&
                                    token.transactions.list
                                        .any((transfer) => transfer.isPending())
                                ? Container(
                                    width: symbolWidth,
                                    height: symbolHeight,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ))
                                : SizedBox.shrink(),
                            isCommunityToken
                                ? Text(
                                    token.symbol,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                : SizedBox.shrink()
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    flex: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      verticalDirection: VerticalDirection.down,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(
                          token.name,
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 15,
                          ),
                        ),
                        // SizedBox(
                        //   width: 5,
                        // ),
                        // SvgPicture.asset(
                        //   'assets/images/go_to_pro.svg',
                        //   width: 10,
                        //   height: 10,
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        overflow: Overflow.visible,
                        alignment: AlignmentDirectional.bottomEnd,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Europa',
                              ),
                              children: <TextSpan>[
                                token.priceInfo != null
                                    ? TextSpan(
                                        text: '\$' + price,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ))
                                    : TextSpan(
                                        text: token.getBalance() +
                                            ' ' +
                                            token.symbol,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          token.priceInfo != null
                              ? Positioned(
                                  bottom: -20,
                                  child: Padding(
                                      child: Text(
                                          token.getBalance() +
                                              ' ' +
                                              token.symbol,
                                          style: TextStyle(
                                              color: Color(0xFF8D8D8D),
                                              fontSize: 10)),
                                      padding: EdgeInsets.only(top: 10)))
                              : SizedBox.shrink()
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}