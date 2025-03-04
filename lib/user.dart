
/*
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User"),
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            UserOption(icon: Icons.person, text: 'Personal Details'),
            UserOption(icon: Icons.directions_car, text: 'Vehicle Details'),
            UserOption(icon: Icons.security, text: 'Insurance Details'),
            UserOption(icon: Icons.local_hospital, text: 'Medical Details'),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Handle emergency contacts
              },
              icon: Icon(Icons.contact_phone),
              label: Text('Emergency Contacts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserOption extends StatelessWidget {
  final IconData icon;
  final String text;

  const UserOption({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(text, style: TextStyle(fontSize: 18)),
        onTap: () {
          // Handle option click
        },
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Details',
      home: UserPage(),
    );
  }
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User"),
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            UserOption(
                icon: Icons.person,
                text: 'Personal Details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PersonalDetailsPage()),
                  );
                }),
            UserOption(
                icon: Icons.directions_car,
                text: 'Vehicle Details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VehicleDetailsPage()),
                  );
                }),
            UserOption(
              icon: Icons.local_hospital,
              text: 'Medical Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicalDetailsPage()),
                );
              },
            ),
            //UserOption(icon: Icons.security, text: 'Insurance Details'),
            //UserOption(icon: Icons.local_hospital, text: 'Medical Details'),
            UserOption(
              icon: Icons.security,
              text: 'Insurance Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsuranceDetailsPage()),
                );
              },
            ),

            /*SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Handle emergency contacts
              },
              icon: Icon(Icons.contact_phone),
              label: Text('Emergency Contacts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),*/
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmergencyContactsPage()),
                );
              },
              icon: Icon(Icons.contact_phone),
              label: Text('Emergency Contacts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const UserOption({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(text, style: TextStyle(fontSize: 18)),
        onTap: onTap,
      ),
    );
  }
}

class VehicleDetailsPage extends StatefulWidget {
  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final TextEditingController rcNoController = TextEditingController();
  final TextEditingController vehicleRegController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("RC Number", rcNoController),
              _buildTextField("Vehicle Registration", vehicleRegController),
              _buildTextField("Model", modelController),
              _buildTextField("Owner Name", ownerNameController),
              //_buildTextField("Insurance Details", insuranceController),
              _buildTextField("Fuel Type", fuelTypeController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Vehicle data added successfully!")),
                    );
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class PersonalDetailsPage extends StatefulWidget {
  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("Name", nameController),
              _buildTextField("Gender", genderController),
              _buildTextField("Blood Group", bloodGroupController),
              _buildTextField("Date of Birth", dobController),
              _buildTextField("Phone Number", phoneController),
              _buildTextField("Address", addressController),
              _buildTextField("Email", emailController),
              _buildTextField("Age", ageController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Personal details added successfully!")),
                    );
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class MedicalDetailsPage extends StatefulWidget {
  @override
  _MedicalDetailsPageState createState() => _MedicalDetailsPageState();
}

class _MedicalDetailsPageState extends State<MedicalDetailsPage> {
  final TextEditingController medicalConditionController =
      TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicationsController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("Medical Conditions", medicalConditionController),
              _buildTextField("Allergies", allergiesController),
              _buildTextField("Medications", medicationsController),
              _buildTextField("Emergency Contact", emergencyContactController),
              _buildTextField("Doctor's Name", doctorNameController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Medical details added successfully!")),
                    );
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class InsuranceDetailsPage extends StatefulWidget {
  @override
  _InsuranceDetailsPageState createState() => _InsuranceDetailsPageState();
}

class _InsuranceDetailsPageState extends State<InsuranceDetailsPage> {
  final TextEditingController policyNumberController = TextEditingController();
  final TextEditingController providerNameController = TextEditingController();
  final TextEditingController coverageController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insurance Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("Policy Number", policyNumberController),
              _buildTextField("Provider Name", providerNameController),
              _buildTextField("Coverage Details", coverageController),
              _buildTextField("Expiry Date", expiryDateController),
              _buildTextField("Contact Number", contactController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Insurance details added successfully!")),
                    );
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class EmergencyContactsPage extends StatefulWidget {
  @override
  _EmergencyContactsPageState createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  List<Map<String, String>> emergencyContacts = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void _addContact() {
    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
      setState(() {
        emergencyContacts.add({
          "name": nameController.text,
          "phone": phoneController.text,
        });
        nameController.clear();
        phoneController.clear();
      });
      Navigator.pop(context); // Close the bottom sheet after adding
    }
  }

  void _removeContact(int index) {
    setState(() {
      emergencyContacts.removeAt(index);
    });
  }

  void _showAddContactDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Contact Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addContact,
                child: Text("Add Contact"),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Contacts"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading:
                          Icon(Icons.contact_phone, color: Colors.redAccent),
                      title: Text(emergencyContacts[index]["name"]!),
                      subtitle: Text(emergencyContacts[index]["phone"]!),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeContact(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _showAddContactDialog,
              icon: Icon(Icons.add),
              label: Text("Add Contact"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}