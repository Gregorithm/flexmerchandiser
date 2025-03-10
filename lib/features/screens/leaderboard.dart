import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexmerchandiser/features/screens/navigationbar/navigationbar.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final List<Map<String, dynamic>> users = [
    {'name': 'Wanjiku Mwangi', 'bookings': 200, 'avatar': 'assets/avatar1.png'},
    {'name': 'Omondi Ochieng', 'bookings': 102, 'avatar': 'assets/avatar2.png'},
    {'name': 'Mutua Kimani', 'bookings': 100, 'avatar': 'assets/avatar3.png'},
    {'name': 'Achieng Otieno', 'bookings': 100, 'avatar': 'assets/avatar4.png'},
    {'name': 'Kamau Njoroge', 'bookings': 98, 'avatar': 'assets/avatar5.png'},
  ];

  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: GoogleFonts.montserrat(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(25),
                    selectedColor: Colors.white,
                    fillColor: Colors.blueGrey,
                    color: Colors.white70,
                    textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                    constraints: const BoxConstraints.expand(height: 40, width: 140),
                    children: const [
                      Text('Weekly'),
                      Text('All Time'),
                    ],
                    isSelected: isSelected,
                    onPressed: (index) {
                      setState(() {
                        for (int i = 0; i < isSelected.length; i++) {
                          isSelected[i] = i == index;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "This feature is due for an update",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage(user['avatar']),
                      ),
                      title: Text(
                        user['name'],
                        style: GoogleFonts.montserrat(
                          fontSize: 18, fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${user['bookings']} bookings',
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: index == 0
                          ? const Icon(Icons.emoji_events, color: Colors.amber, size: 28)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarWidget(),
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[200],
    );
  }
}