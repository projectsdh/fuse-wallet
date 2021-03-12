import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/redux/viewsmodels/contacts.dart';
import 'package:fusecash/features/contacts/widgets/send_to_account.dart';
import 'package:fusecash/features/contacts/widgets/contact_tile.dart';
import 'package:fusecash/features/contacts/widgets/list_header.dart';
import 'package:fusecash/features/contacts/widgets/search_panel.dart';
import 'package:fusecash/utils/contacts.dart';
import 'package:fusecash/utils/phone.dart';
import 'package:fusecash/utils/send.dart';
import "package:ethereum_address/ethereum_address.dart";
import 'package:fusecash/widgets/my_scaffold.dart';
import 'package:fusecash/widgets/preloader.dart';

class ContactsList extends StatefulWidget {
  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  List<Contact> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, ContactsViewModel>(
      distinct: true,
      onInitialBuild: (viewModel) {
        Segment.screen(screenName: '/contacts-screen');
      },
      converter: ContactsViewModel.fromStore,
      builder: (_, viewModel) {
        return _contacts != null
            ? MyScaffold(
                automaticallyImplyLeading: false,
                title: I18n.of(context).send_to,
                body: InkWell(
                  onTap: () {
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: CustomScrollView(
                          slivers: <Widget>[..._buildPageList(viewModel)],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: Preloader(),
              );
      },
    );
  }

  Future<void> refreshContacts() async {
    List<Contact> contacts = await Contacts.getContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
      });
    }

    filterList();
    searchController.addListener(filterList);

    if (Platform.isAndroid) {
      for (final contact in contacts) {
        ContactsService.getAvatar(contact).then((avatar) {
          if (avatar == null) return;
          if (mounted) {
            setState(() => contact.avatar = avatar);
          }
        });
      }
    }
  }

  filterList() {
    List<Contact> users = [];
    users.addAll(_contacts);
    if (searchController.text.isNotEmpty) {
      users.retainWhere((user) => user.displayName
          .toLowerCase()
          .contains(searchController.text.toLowerCase()));
    }

    if (this.mounted) {
      setState(() {
        filteredUsers = users;
      });
    }
  }

  void resetSearch() {
    FocusScope.of(context).unfocus();
    if (mounted) {
      setState(() {
        searchController.text = '';
      });
    }
  }

  SliverList listBody(ContactsViewModel viewModel, List<Contact> group) {
    List<Widget> listItems = List();
    for (Contact user in group) {
      Iterable<Item> phones = user.phones
          .map((e) => Item(
              label: e.label, value: clearNotNumbersAndPlusSymbol(e.value)))
          .toSet()
          .toList();
      for (Item phone in phones) {
        listItems.add(
          ContactTile(
            image: user.avatar != null && user.avatar.isNotEmpty
                ? MemoryImage(user.avatar)
                : null,
            displayName: user.displayName,
            phoneNumber: phone.value,
            onTap: () {
              resetSearch();
              sendToContact(
                ExtendedNavigator.named('contactsRouter').context,
                user.displayName,
                phone.value,
                isoCode: viewModel.isoCode,
                countryCode: viewModel.countryCode,
                avatar: user.avatar != null && user.avatar.isNotEmpty
                    ? MemoryImage(user.avatar)
                    : new AssetImage('assets/images/anom.png'),
              );
            },
            trailing: Text(
              phone.value,
              style: TextStyle(fontSize: 13),
            ),
          ),
        );
      }
    }
    return SliverList(
      delegate: SliverChildListDelegate(listItems),
    );
  }

  List<Widget> _buildPageList(ContactsViewModel viewModel) {
    List<Widget> listItems = List();

    listItems.add(SearchPanel(
      searchController: searchController,
    ));

    // if (searchController.text.isEmpty) {
    // listItems.add(RecentContacts());
    // } else
    if (isValidEthereumAddress(searchController.text)) {
      listItems.add(
        SendToAccount(
          accountAddress: searchController.text,
          resetSearch: resetSearch,
        ),
      );
    }

    Map<String, List<Contact>> groups = new Map<String, List<Contact>>();
    for (Contact c in filteredUsers) {
      String groupName = c.displayName[0];
      if (!groups.containsKey(groupName)) {
        groups[groupName] = new List<Contact>();
      }
      groups[groupName].add(c);
    }

    List<String> titles = groups.keys.toList()..sort();

    for (String title in titles) {
      List<Contact> group = groups[title];
      listItems.add(ListHeader(title: title));
      listItems.add(listBody(viewModel, group));
    }

    return listItems;
  }
}
