import 'package:digitalrand/models/transactions/transaction.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:digitalrand/generated/i18n.dart';
import 'package:digitalrand/models/transactions/transfer.dart';
import 'package:digitalrand/models/app_state.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:digitalrand/models/views/home.dart';
import 'package:digitalrand/screens/cash_home/transaction_tile.dart';

class Feed extends StatefulWidget {
  @override
  createState() => new FeedState();
}

class FeedState extends State<Feed> {
  FeedState();

  @override
  void initState() {
    super.initState();
  }

  void onChange(HomeViewModel viewModel, BuildContext context) async {
    viewModel.setIdentifier();
    viewModel.startProcessingJobs();
    viewModel.startTransfersFetching();
    viewModel.listenToBranch();
    if (viewModel.isoCode == null) {
      Locale myLocale = Localizations.localeOf(context);
      Map localeData = codes.firstWhere(
          (Map code) => code['code'] == myLocale.countryCode,
          orElse: () => null);
      viewModel.setCountyCode(CountryCode(
          dialCode: localeData['dial_code'], code: localeData['code']));
    }
    if (!viewModel.isCommunityLoading &&
        viewModel.branchAddress != null &&
        viewModel.branchAddress != "" &&
        viewModel.walletAddress != '') {
      viewModel.branchCommunityUpdate();
    }
    if (!viewModel.isCommunityLoading &&
        !viewModel.isCommunityFetched &&
        viewModel.isBranchDataReceived &&
        viewModel.walletAddress != '') {
      viewModel.switchCommunity(viewModel.communityAddress);
    }
  }

  @override
  Widget build(BuildContext _context) {
    return new StoreConnector<AppState, HomeViewModel>(
        converter: HomeViewModel.fromStore,
        onInitialBuild: (viewModel) {
          onChange(viewModel, context);
        },
        onWillChange: (prevViewModel, nextViewModel) {
          onChange(nextViewModel, context);
        },
        builder: (_, viewModel) {
          final bool isWalletCreated = 'created' == viewModel.walletStatus;
          final Transfer generateWallet = new Transfer(
              type: 'RECEIVE',
              text: !isWalletCreated
                  ? I18n.of(context).generating_wallet
                  : I18n.of(context).generated_wallet,
              status: !isWalletCreated ? 'PENDING' : 'CONFIRMED',
              jobId: 'generateWallet');
          final List<Transaction> feedList = [
            ...viewModel.feedList,
            generateWallet,
          ];
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    itemCount: feedList?.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return TransactionTile(transfer: feedList[index]);
                    }),
              )
            ],
          );
        });
  }
}
