import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const historyLength = 5;

  List<String> _searchHistory = [];

  bool isLoading = false;

  late List<String> filteredSearchHistory;

  String? selectedTerm;

  Future<QuerySnapshot>? searchResultsFuture;
  final FirebaseAuth auth = FirebaseAuth.instance;

  handleSearch(String query) {
    setState(() {
      isLoading = true;
    });
    try {
      Future<QuerySnapshot> users = usersRef
          .where("username", isGreaterThanOrEqualTo: query)
          .where("username", isLessThanOrEqualTo: query + "\uf8ff")
          .get();
      setState(() {
        searchResultsFuture = users;
      });
    } catch (err) {
      print(err);
    }
    setState(() {
      isLoading = false;
    });
  }

  List<String> filterSearchTerms({String? filter}) {
    if (filter != null && filter.isNotEmpty) {
      return _searchHistory.reversed.where((element) => false).toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }
    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((t) => t == term);
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  late FloatingSearchBarController controller;

  late final uid;

  // List<String> getList = [];

  @override
  void initState() {
    super.initState();
    final User user = auth.currentUser!;
    uid = user.uid;
    controller = FloatingSearchBarController();
    filteredSearchHistory = filterSearchTerms(filter: null);
    // ignore: todo
    // TODO: Implement shared preferences to store search history
    // _prefs.then((SharedPreferences prefs) {
    //   filteredSearchHistory = prefs.getStringList('search_history') ?? [];
    // });
    // print(filteredSearchHistory);
  }

  @override
  void dispose() {
    controller.dispose();
    // _prefs.then((pref) {
    //   pref.setStringList('search_history', _searchHistory);
    // });
    // print(_searchHistory);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediaQuery = MediaQuery.of(context);

    ScreenUtil.init(
      BoxConstraints(
        maxWidth: mediaQuery.size.width,
        maxHeight: mediaQuery.size.height,
      ),
      designSize: Size(392.75, 856.75),
      orientation: Orientation.portrait,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: CustomColors.backgroundColor,
        child: FloatingSearchBar(
          transition: CircularFloatingSearchBarTransition(),
          transitionDuration: Duration(milliseconds: 500),
          transitionCurve: Curves.linear,
          elevation: 1.5,
          // progress: true,
          margins: EdgeInsets.only(
              left: 22.w, right: 22.w, top: mediaQuery.viewPadding.top + 8.h),
          borderRadius: BorderRadius.circular(8),
          padding: EdgeInsets.symmetric(horizontal: 16),
          physics: BouncingScrollPhysics(),
          controller: controller,
          clearQueryOnClose: false,
          title: selectedTerm == null
              ? Text(
                  'Search Text',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 15.ssp,
                      color: CustomColors.textFieldHintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Text(
                  selectedTerm!,
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 15.ssp,
                      color: CustomColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          hint: 'Search',
          hintStyle: GoogleFonts.openSans(
            textStyle: TextStyle(
              // ignore: deprecated_member_use
              fontSize: 15.ssp,
              color: CustomColors.textFieldHintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          leadingActions: [
            FloatingSearchBarAction.icon(
              icon: Icon(
                CustomIcons.search,
                color: CustomColors.textFieldHintColor,
                size: 18,
              ),
              onTap: () {},
            )
          ],
          actions: [
            FloatingSearchBarAction.icon(
              showIfOpened: true,
              icon: Icon(
                Icons.close_rounded,
                color: CustomColors.textFieldHintColor,
                size: 20,
              ),
              onTap: () {
                // print(controller.toString());
                controller.clear();
                setState(() {
                  selectedTerm = null;
                });
              },
            )
          ],
          onQueryChanged: (query) {
            setState(() {
              isLoading = true;
              filteredSearchHistory = filterSearchTerms(filter: query);
            });
          },
          onSubmitted: (query) {
            setState(() {
              isLoading = true;
              addSearchTerm(query);
              selectedTerm = query;
            });
            handleSearch(query);
            controller.close();
          },
          body: FutureBuilder(
              future: searchResultsFuture,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return selectedTerm != null
                      ? Center(child: CustomCircularBar(size: 75, padding: 22))
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/user_search.png',
                                height: 200,
                                width: 200,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Search'.toUpperCase(),
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    // ignore: deprecated_member_use
                                    fontSize: 14.ssp,
                                    color: CustomColors.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                }
                List<Users> searchResults = [];
                snapshot.data!.docs.forEach((doc) {
                  Users user = Users.fromDocument(doc);
                  if (user.id != uid) searchResults.add(user);
                });
                return SearchResultsListView(
                  searchTerm: selectedTerm,
                  searchItems: searchResults,
                  isLoading: isLoading,
                );
              }),
          builder: (context, transition) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: Colors.white,
                elevation: 4,
                child: Builder(
                  builder: (context) {
                    if (filteredSearchHistory.isEmpty &&
                        controller.query.isEmpty) {
                      return Container(
                        height: 56,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          'Start searching',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              // ignore: deprecated_member_use
                              fontSize: 15.ssp,
                              color: CustomColors.textFieldHintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    } else if (filteredSearchHistory.isEmpty) {
                      return ListTile(
                        title: Text(controller.query),
                        leading: const Icon(
                          CustomIcons.search,
                          size: 20,
                          color: CustomColors.textFieldHintColor,
                        ),
                        onTap: () {
                          setState(() {
                            isLoading = true;
                            addSearchTerm(controller.query);
                            selectedTerm = controller.query;
                          });
                          handleSearch(controller.query);
                          controller.close();
                        },
                      );
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: filteredSearchHistory
                            .map(
                              (term) => ListTile(
                                title: Text(
                                  term,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: const Icon(
                                  Icons.restore_rounded,
                                  color: CustomColors.textFieldHintColor,
                                  size: 20,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: CustomColors.textFieldHintColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      deleteSearchTerm(term);
                                    });
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    isLoading = true;
                                    putSearchTermFirst(term);
                                    selectedTerm = term;
                                  });
                                  handleSearch(term);
                                  controller.close();
                                },
                              ),
                            )
                            .toList(),
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchResultsListView extends StatefulWidget {
  final String? searchTerm;
  final List<Users> searchItems;
  final bool isLoading;

  SearchResultsListView(
      {Key? key,
      required this.searchTerm,
      required this.searchItems,
      required this.isLoading})
      : super(key: key);

  @override
  _SearchResultsListViewState createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
  var currentAddresses = [];

  _getLoc() async {
    currentAddresses = List.filled(widget.searchItems.length, '');
    var currentAddress = [];
    for (int i = 0; i < widget.searchItems.length; i++) {
      final geoPoint = widget.searchItems[i].loc;
      final lat = geoPoint.latitude;
      final long = geoPoint.longitude;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
        Placemark place = placemarks[0];
        currentAddress.add('${place.locality}');
      } catch (e) {
        print(e);
      }
    }

    return currentAddress;
  }

  bool isLoaded = false;

  @override
  void initState() {
    _getLoc().then((value) {
      var list = value;
      currentAddresses = list;
      setState(() {
        currentAddresses = list;
        isLoaded = true;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SearchResultsListView oldWidget) {
    _getLoc().then((value) {
      var list = value;
      currentAddresses = list;
      isLoaded = true;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchTerm == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/user_search.png',
              height: 200,
              width: 200,
            ),
            SizedBox(height: 22.h),
            Text(
              'Search'.toUpperCase(),
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 14.ssp,
                  color: CustomColors.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      );
    }

    final fsb = FloatingSearchBar.of(context);

    if (widget.isLoading) {
      return Center(child: CustomCircularBar(size: 75, padding: 22));
    }

    return widget.searchItems.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.all(22),
                  child: Image.asset(
                    'assets/images/not_found_2.png',
                    height: 200,
                    width: 200,
                  ),
                ),
                // SizedBox(height: 22.h),
                Text(
                  'User not found'.toUpperCase(),
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 14.ssp,
                      color: CustomColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: CustomColors.whiteColor,
            ),
            margin: EdgeInsets.only(
              top: fsb!.style.height + fsb.style.margins.vertical + 22.h,
              bottom: 22.h,
              left: 22.w,
              right: 22.w,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: isLoaded
                  ? ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: BouncingScrollPhysics(),
                      itemCount: widget.searchItems.length,
                      itemBuilder: (context, position) {
                        return Column(
                          children: [
                            Material(
                              color: CustomColors.whiteColor,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      UserProfile.routeName,
                                      arguments:
                                          widget.searchItems[position].id);
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        CustomColors.textFieldFillColor,
                                    backgroundImage: CachedNetworkImageProvider(
                                        widget.searchItems[position].photoUrl),
                                  ),
                                  title: Text(
                                      '${widget.searchItems[position].username}'),
                                  subtitle: Row(
                                    children: [
                                      Icon(
                                        CustomIcons.location,
                                        size: 14,
                                        color: CustomColors.iconColor,
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        currentAddresses[position],
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            // ignore: deprecated_member_use
                                            fontSize: 14.ssp,
                                            color: CustomColors.iconColor,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  enableFeedback: true,
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              indent: 22.w,
                              endIndent: 22.w,
                            )
                          ],
                        );
                      })
                  : Center(child: CustomCircularBar(size: 75, padding: 22)),
            ),
          );
  }
}
