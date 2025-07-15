import 'dart:async';
import 'package:atl_membership/screens/homescreen.dart';
import 'package:atl_membership/services/TeamTableService.dart';
import 'package:atl_membership/models/ModelProvider.dart';
import 'package:atl_membership/controllers/UserTableController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Teamscreen extends StatefulWidget {
  const Teamscreen({super.key});

  @override
  State<Teamscreen> createState() => _TeamscreenState();
}

class _TeamscreenState extends State<Teamscreen> {
  late final UserController _userController;
  TeamTable? _currentTeam;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userController = Get.find<UserController>();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get all teams for the user
      final teams = await TeamTableService.getUserTeams(_userController.userId.value);

      if (teams.isNotEmpty) {
        setState(() {
          _currentTeam = teams.first; // Assuming user is in one team
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "You are not part of any team.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading team data.";
        _isLoading = false;
      });
    }
  }

  void _copyTeamCode() {
    if (_currentTeam?.team_code != null) {
      Clipboard.setData(ClipboardData(text: _currentTeam!.team_code!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Team code copied to clipboard"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Leave Current Team",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 48),
              SizedBox(height: 16),
              Text(
                "Are you sure you want to leave the current team?",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Team Code: ${_currentTeam?.team_code ?? 'Unknown'}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _leaveTeam();
              },
              child: const Text(
                "Leave",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _leaveTeam() async {
    if (_currentTeam == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Leaving team..."),
          ],
        ),
      ),
    );

    try {
      final success = await TeamTableService.exitTeam(
          _currentTeam!.team_code!,
          _userController.userId.value
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        Get.snackbar(
          "Success",
          "Successfully left the team",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate back to home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to leave team. Please try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      Get.snackbar(
        "Error",
        "An error occurred while leaving the team.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _refreshTeamData() {
    _loadTeamData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshTeamData(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // AppBar replacement with back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black, size: 30),
                        ),
                        IconButton(
                          onPressed: _refreshTeamData,
                          icon: const Icon(Icons.refresh,
                              color: Colors.blue, size: 30),
                        ),
                      ],
                    ),
                  ),

                  // Team avatar
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group,
                        size: 100, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // Team title
                  const Text(
                    'YOUR TEAM',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Loading state
                  if (_isLoading)
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text("Loading team data..."),
                      ],
                    )

                  // Error state
                  else if (_errorMessage != null)
                    Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 64),
                        SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshTeamData,
                          child: Text("Retry"),
                        ),
                      ],
                    )

                  // Team data
                  else if (_currentTeam != null) ...[
                      // Team code section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                _currentTeam!.team_code ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _copyTeamCode,
                            icon: const Icon(Icons.copy),
                            tooltip: "Copy team code",
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Share instruction text
                      const Text(
                        'Share this code with your friends\nto join your team',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),

                      // Team info section
                      if (_currentTeam!.school_name != null ||
                          _currentTeam!.district != null ||
                          _currentTeam!.mandal != null)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Team Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (_currentTeam!.school_name != null)
                                Text("School: ${_currentTeam!.school_name}"),
                              if (_currentTeam!.district != null)
                                Text("District: ${_currentTeam!.district}"),
                              if (_currentTeam!.mandal != null)
                                Text("Mandal: ${_currentTeam!.mandal}"),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Divider
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        height: 1,
                        color: Colors.black.withOpacity(0.2),
                      ),

                      const SizedBox(height: 20),

                      // Team members section
                      Column(
                        children: [
                          const Text(
                            'Team Members',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (_currentTeam!.team_members?.isEmpty ?? true)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No team members found.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          else
                            Column(
                              children: List.generate(
                                _currentTeam!.team_members!.length,
                                    (index) {
                                  final memberId = _currentTeam!.team_members![index];
                                  final isCurrentUser = memberId == _userController.userId.value;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 20),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCurrentUser ? Icons.person : Icons.person_outline,
                                          color: isCurrentUser ? Colors.blue : Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            memberId + (isCurrentUser ? ' (You)' : ''),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                          // Leave team button
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _showLeaveDialog(context),
                              child: const Text(
                                'Leave Team',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
