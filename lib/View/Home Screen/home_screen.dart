import 'package:final_exam/Controller/home_Screen_controller.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await HomeScreenController.initDb();
        await HomeScreenController.getAllAssets();
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asset Management"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          customBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          final asset = HomeScreenController.assetlist[index];
          return ListTile(
            title: Text(asset["name"]),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type: ${asset["type"]}"),
                Text("Description: ${asset["description"]}"),
                Text("Serial: ${asset["serialNumber"]}"),
                Row(
                  children: [
                    Text(
                      asset["availability"] == 1
                          ? "Borrower Status: Available"
                          : "Borrower Status: Not Available",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    asset["availability"] == 1
                        ? CircleAvatar(
                            maxRadius: 5,
                            backgroundColor: Colors.blue,
                          )
                        : CircleAvatar(
                            maxRadius: 5,
                            backgroundColor: Colors.red,
                          )
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    customBottomSheet(
                      context,
                      isEdit: true,
                      currentType: asset["type"],
                      currentName: asset["name"],
                      currentDescription: asset["description"],
                      currentSerialNumber: asset["serialNumber"],
                      currentAvailability: asset["availability"],
                      assetId: asset["id"],
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await HomeScreenController.deleteAsset(asset["id"]);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: HomeScreenController.assetlist.length,
      ),
    );
  }

  Future<dynamic> customBottomSheet(BuildContext context,
      {bool isEdit = false,
      String? currentType,
      String? currentName,
      String? currentDescription,
      String? currentSerialNumber,
      int? currentAvailability,
      int? assetId}) {
    TextEditingController typeController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController serialNumberController = TextEditingController();
    bool isAvailable = currentAvailability == 1;

    if (isEdit) {
      typeController.text = currentType ?? "";
      nameController.text = currentName ?? "";
      descriptionController.text = currentDescription ?? "";
      serialNumberController.text = currentSerialNumber ?? "";
    }

    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: "Asset Type",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Asset Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: serialNumberController,
                  decoration: const InputDecoration(
                    labelText: "Serial Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Availability"),
                    Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        setModalState(() {
                          isAvailable = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                         
                          if (isEdit) {
                            await HomeScreenController.updateAssets(
                              typeController.text,
                              nameController.text,
                              descriptionController.text,
                              serialNumberController.text,
                              isAvailable ? 1 : 0,
                              assetId!,
                            );
                          } else {
                            await HomeScreenController.addAsset(
                              typeController.text,
                              nameController.text,
                              descriptionController.text,
                              serialNumberController.text,
                              isAvailable ? 1 : 0,
                            );
                          }
                          await HomeScreenController.getAllAssets();
                          if (context.mounted) {
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
