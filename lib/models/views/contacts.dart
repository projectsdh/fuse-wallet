import 'package:contacts_service/contacts_service.dart';
import 'package:digitalrand/constans/exchangable_tokens.dart';
import 'package:digitalrand/utils/addresses.dart';
import 'package:equatable/equatable.dart';
import 'package:digitalrand/models/app_state.dart';
import 'package:digitalrand/models/community/business.dart';
import 'package:digitalrand/models/community/community.dart';
import 'package:digitalrand/models/plugins/fee_base.dart';
import 'package:digitalrand/models/tokens/token.dart';
import 'package:digitalrand/models/transactions/transactions.dart';
import 'package:digitalrand/redux/actions/cash_wallet_actions.dart';
import 'package:digitalrand/redux/actions/user_actions.dart';
import 'package:redux/redux.dart';

class ContactsViewModel extends Equatable {
  final List<Contact> contacts;
  final Token token;
  final bool isContactsSynced;
  final Function(List<Contact>) syncContacts;
  final Transactions transactions;
  final Map<String, String> reverseContacts;
  final String countryCode;
  final String isoCode;
  final Function() syncContactsRejected;
  final List<Business> businesses;
  final Function(String eventName) trackCall;
  final Function(Map<String, dynamic> traits) idenyifyCall;
  final Token tokenDAI;
  final Community community;
  final FeePlugin feePlugin;

  ContactsViewModel(
      {this.contacts,
      this.token,
      this.syncContacts,
      this.isContactsSynced,
      this.feePlugin,
      this.tokenDAI,
      this.transactions,
      this.reverseContacts,
      this.countryCode,
      this.community,
      this.isoCode,
      this.businesses,
      this.syncContactsRejected,
      this.trackCall,
      this.idenyifyCall});

  static ContactsViewModel fromStore(Store<AppState> store) {
    String communityAddres = store.state.cashWalletState.communityAddress;
    Community community = store.state.cashWalletState.communities[communityAddres];
    Token token = store.state.proWalletState.erc20Tokens.containsKey(daiTokenAddress.toLowerCase())
        ? store.state.proWalletState.erc20Tokens[daiTokenAddress.toLowerCase()]
        : daiToken;
    return ContactsViewModel(
        tokenDAI: token,
        // feePlugin: community.plugins.foreignTransfers : null,
        isoCode: store.state.userState.isoCode,
        businesses: community?.businesses ?? [],
        isContactsSynced: store.state.userState.isContactsSynced,
        contacts: store.state.userState?.contacts ?? [],
        token: community?.token,
        community: community,
        transactions: community?.token?.transactions,
        reverseContacts: store.state.userState.reverseContacts,
        countryCode: store.state.userState.countryCode,
        syncContacts: (List<Contact> contacts) {
          store.dispatch(syncContactsCall(contacts));
        },
        syncContactsRejected: () {
          store.dispatch(new SyncContactsRejected());
        },
        trackCall: (String eventName) {
          store.dispatch(segmentTrackCall(eventName));
        },
        idenyifyCall: (Map<String, dynamic> traits) {
          store.dispatch(segmentIdentifyCall(traits));
        });
  }

  @override
  List<Object> get props => [
    contacts,
    token,
    isContactsSynced,
    transactions,
    reverseContacts,
    countryCode,
    businesses,
    isoCode,
    community,
    tokenDAI
  ];
}
