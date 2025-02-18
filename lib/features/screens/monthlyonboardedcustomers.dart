import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardedCustomersPage extends StatelessWidget {
  final String selectedMonth;
  final int monthIndex;

  OnboardedCustomersPage({required this.selectedMonth, required this.monthIndex});

  // Dummy customer data for each month
  final Map<int, List<Map<String, String>>> dummyCustomers = {
    0: [
      {"name": "Mwangi Kimani", "phone": "+254712345678"},
      {"name": "Wanjiku Ndungu", "phone": "+254723456789"},
      {"name": "Otieno Ouma", "phone": "+254734567890"},
      {"name": "Mutuku Musyoka", "phone": "+254745678901"},
      {"name": "Achieng Awuor", "phone": "+254756789012"},
      {"name": "Kamau Waithera", "phone": "+254767890123"},
    ],
    1: [
      {"name": "Kariuki Njoroge", "phone": "+254711234567"},
      {"name": "Nduta Wanjiru", "phone": "+254722345678"},
      {"name": "Omwami Atieno", "phone": "+254733456789"},
      {"name": "Mwangi Wafula", "phone": "+254744567890"},
      {"name": "Chebet Kiprop", "phone": "+254755678901"},
      {"name": "Otieno Owino", "phone": "+254766789012"},
      {"name": "Mumbi Nyambura", "phone": "+254777890123"},
      {"name": "Baraka Mutuku", "phone": "+254788901234"},
      {"name": "Musa Charo", "phone": "+254799012345"},
      {"name": "Naliaka Wekesa", "phone": "+254710123456"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> customers = dummyCustomers[monthIndex] ?? [];
    int customerCount = customers.length;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Customers - $selectedMonth",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, // 4% of screen width
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Onboarded Customers",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.05, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: screenHeight * 0.015), // Dynamic spacing

              // Customer Count + Flaming Gear Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Total Customers: $customerCount",
                      style: GoogleFonts.montserrat(
                        fontSize: screenWidth * 0.04, // Dynamic font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.local_fire_department, color: Colors.red, size: screenWidth * 0.06),
                ],
              ),
              SizedBox(height: screenHeight * 0.015), // Dynamic spacing

              // Flaming Gear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: customerCount / 12, // Normalize based on max 12 customers
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  minHeight: screenHeight * 0.008, // Responsive height
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Dynamic spacing

              // Customers List
              Expanded(
                child: ListView.separated(
                  itemCount: customers.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015, // Responsive padding
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer["name"]!,
                            style: GoogleFonts.montserrat(
                              fontSize: screenWidth * 0.045, // Responsive font
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005), // Responsive spacing
                          Text(
                            "Phone: ${customer["phone"]!}",
                            style: GoogleFonts.montserrat(
                              fontSize: screenWidth * 0.04, // Responsive font
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}