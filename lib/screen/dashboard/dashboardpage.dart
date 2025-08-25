import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hpackweb/screen/dashboard/approvallist.dart';
import 'package:hpackweb/loginpage.dart';
import 'package:hpackweb/models/pendingModel.dart';
import 'package:hpackweb/screen/approvaldetails/approvaldetails.dart';
import 'package:hpackweb/screen/dashboard/addpricelist.dart';
import 'package:hpackweb/screen/reports/reportdetail.dart';
import 'package:hpackweb/screen/reports/reportlist.dart';
import 'package:hpackweb/utils/apputils.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:hpackweb/widgets/searchwidget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late String selectedPage;
  ApprovalDetail? selectedApproval;
  bool showApprovalDetail = false;
  final TextEditingController searchController = TextEditingController();

  late Map<String, List<String>> menu;
  final Map<String, bool> expandedState = {'Reports': false};

  @override
  void initState() {
    super.initState();

    bool isSupervisor = Prefs.getIsSupervisor() == "Y";

    // Build menu based on role
    menu = {};
    if (!isSupervisor) {
      menu['Price List Form'] = [];
      menu['Reports'] = [];
      selectedPage = 'Price List Form';
    }

    if (isSupervisor) {
      menu['Approve Price List'] = [];
      selectedPage = 'Approve Price List';
    }
  }

  Widget getPage(String page) {
    switch (page) {
      case 'Price List Form':
        return AddPriceListScreen();
      case 'Approve Price List':
        return Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child:
                    showApprovalDetail && selectedApproval != null
                        ? ApprovalDetailPage(
                          detail: selectedApproval!,
                          onClose: () {
                            setState(() {
                              showApprovalDetail = false;
                              selectedApproval = null;
                            });
                          },
                        )
                        : ApprovalListPage(
                          searchController: searchController,
                          onRowTap: (detail) {
                            setState(() {
                              selectedApproval = detail;
                              showApprovalDetail = true;
                            });
                          },
                        ),
              ),
            ),
          ],
        );
      case 'Reports':
        return Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child:
                    showApprovalDetail && selectedApproval != null
                        ? ReportDetailPage(
                          detail: selectedApproval!,
                          onClose: () {
                            setState(() {
                              showApprovalDetail = false;
                              selectedApproval = null;
                            });
                          },
                        )
                        : ReportHeaderPage(
                          searchController: searchController,
                          onRowTap: (detail) {
                            setState(() {
                              selectedApproval = detail;
                              showApprovalDetail = true;
                            });
                          },
                        ),
              ),
            ),
          ],
        );
      default:
        return Center(child: Text("$page Page"));
    }
  }

  IconData _getIcon(String title) {
    switch (title) {
      case 'Price List Form':
        return CupertinoIcons.archivebox_fill;
      case 'Approve Price List':
        return Icons.check_circle_outline;
      case 'Reports':
        return Icons.check_circle_outline;
      default:
        return Icons.circle;
    }
  }

  void forcelogout() {
    AppUtils.pop(context);
    Prefs.setLoggedIn(false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void exitpopup() => AppUtils.pop(context);

  @override
  Widget build(BuildContext context) {
    final isSupervisor = Prefs.getIsSupervisor() == "Y";

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Side Menu
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/hpacklogo.png', width: 100),
                    ],
                  ),
                ),
                ...menu.entries.map((entry) {
                  final key = entry.key;
                  final children = entry.value;
                  final isExpandable = children.isNotEmpty;
                  final isExpanded = expandedState[key] ?? false;
                  final isSelected = selectedPage == key;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          if (isExpandable) {
                            setState(() => expandedState[key] = !isExpanded);
                          } else {
                            setState(() => selectedPage = key);
                          }
                        },
                        child: Container(
                          color:
                              isSelected
                                  ? const Color(0xFFE6F0FF)
                                  : Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 50,
                                color:
                                    isSelected
                                        ? const Color(0xFF0176D3)
                                        : Colors.transparent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  leading: Icon(
                                    _getIcon(key),
                                    color:
                                        isSelected
                                            ? const Color(0xFF0176D3)
                                            : Colors.black54,
                                  ),
                                  title: Text(
                                    key,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? const Color(0xFF0176D3)
                                              : Colors.black87,
                                    ),
                                  ),
                                  trailing:
                                      isExpandable
                                          ? Icon(
                                            isExpanded
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpandable && isExpanded)
                        ...children.map((child) {
                          final isChildSelected = selectedPage == child;
                          return InkWell(
                            onTap: () => setState(() => selectedPage = child),
                            child: Container(
                              color:
                                  isChildSelected
                                      ? const Color(0xFFE6F0FF)
                                      : Colors.transparent,
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 48,
                                    color:
                                        isChildSelected
                                            ? const Color(0xFF0176D3)
                                            : Colors.transparent,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        left: 32,
                                        right: 12,
                                      ),
                                      title: Text(
                                        child,
                                        style: TextStyle(
                                          fontWeight:
                                              isChildSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isChildSelected
                                                  ? const Color(0xFF0176D3)
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 400,
                        height: 60,
                        child: Searchbar(
                          controller: searchController,
                          onSearch: (query) => setState(() {}),
                          onClear: () {
                            searchController.clear();
                            setState(() {});
                          },
                        ),
                      ),
                      Row(
                        children: [
                          // SizedBox(width: 5),
                          // AppUtils.buildNormalText(
                          //   text: Prefs.getFromMailID() ?? "No Email",
                          //   color: Colors.black54,
                          // ),
                          // SizedBox(width: 5),
                          // AppUtils.buildNormalText(
                          //   text: Prefs.getToMailID() ?? "No Email",
                          //   color: Colors.black54,
                          // ),
                          // SizedBox(width: 10),
                          CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/profile.png',
                            ),
                          ),
                          SizedBox(width: 8),

                          Column(
                            children: [
                              SizedBox(height: 10),
                              Text(
                                Prefs.getName() ?? 'Guest',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              AppUtils.buildNormalText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: Prefs.getFromMailID() ?? "",
                                color: Colors.black54,
                              ),
                            ],
                          ),
                          SizedBox(width: 16),

                          InkWell(
                            onTap: () {
                              AppUtils.showconfirmDialog(
                                context,
                                'Do you want to Logout?',
                                "Yes",
                                "No",
                                forcelogout,
                                exitpopup,
                              );
                            },
                            child: Icon(Icons.logout, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Body
                Expanded(child: getPage(selectedPage)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
