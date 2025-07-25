// // Sidebar MenuItem model
// import 'package:flutter/material.dart';
// import 'package:hpackweb/priceupdateform.dart';

// import 'dashboardpage.dart';
// import 'mailpage.dart';

// class MenuItem {
//   final String title;
//   final IconData icon;
//   final Widget page;

//   MenuItem({required this.title, required this.icon, required this.page});
// }

// // Main Dashboard Layout
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int selectedIndex = 0;

//   final List<MenuItem> menuItems = [
//     MenuItem(title: 'Dashboard', icon: Icons.dashboard, page: DashboardPage()),
//     MenuItem(
//       title: 'Price Update',
//       icon: Icons.mail,
//       page: PriceUpdateScreen(),
//     ),
//     MenuItem(title: 'Approval', icon: Icons.label, page: PriceUpdateScreen()),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           Container(
//             width: 250,
//             color: Colors.blue[800],
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 30,
//                     horizontal: 20,
//                   ),
//                   color: Colors.blue[900],
//                   child: Row(
//                     children: [
//                       const CircleAvatar(
//                         backgroundImage: AssetImage(
//                           'assets/images/profile.png',
//                         ), // Replace with your image
//                         radius: 24,
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
//                           Text(
//                             "Arjun Makwana",
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                           Text(
//                             "Lead UI/UX Designer",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ...List.generate(menuItems.length, (index) {
//                   final isSelected = selectedIndex == index;
//                   final item = menuItems[index];
//                   return InkWell(
//                     onTap: () => setState(() => selectedIndex = index),
//                     child: Container(
//                       color: isSelected ? Colors.white : Colors.transparent,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 14,
//                         horizontal: 20,
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             item.icon,
//                             color: isSelected ? Colors.blue[800] : Colors.white,
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             item.title,
//                             style: TextStyle(
//                               color:
//                                   isSelected ? Colors.blue[800] : Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 InkWell(
//                   onTap: () {
//                     print("Logout clicked");
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     color: Colors.white,
//                     height: 60,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           menuItems[selectedIndex].title,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Icon(Icons.logout),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     color: Colors.grey[100],
//                     child: menuItems[selectedIndex].page,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Sidebar Widget
// class Sidebar extends StatelessWidget {
//   final List<MenuItem> menuItems;
//   final int selectedIndex;
//   final Function(int) onItemSelected;

//   const Sidebar({
//     super.key,
//     required this.menuItems,
//     required this.selectedIndex,
//     required this.onItemSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 220,
//       color: Colors.blue.shade800,
//       child: Column(
//         children: [
//           SizedBox(height: 50),
//           for (int i = 0; i < menuItems.length; i++)
//             ListTile(
//               leading: Icon(menuItems[i].icon, color: Colors.white),
//               title: Text(
//                 menuItems[i].title,
//                 style: TextStyle(color: Colors.white),
//               ),
//               tileColor:
//                   selectedIndex == i
//                       ? Colors.blue.shade400
//                       : Colors.transparent,
//               onTap: () => onItemSelected(i),
//             ),
//         ],
//       ),
//     );
//   }
// }
