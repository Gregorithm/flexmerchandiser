import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // POST request handler
  static Future<dynamic> postRequest({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Function(dynamic response)? onSuccess,
    Function(String error)? onError,
    BuildContext? context,
    required bool showLoader,
  }) async {
    try {
      final requestHeaders = headers ??
          {
            "Content-Type": "application/json",
            "Authorization":
                "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2xvZ2luIiwiaWF0IjoxNzM3OTk2NTE4LCJleHAiOjYwMDAxNzM3OTk2NDU4LCJuYmYiOjE3Mzc5OTY1MTgsImp0aSI6IjlhWFhuOFZUWTc1Z3FvamEiLCJzdWIiOjIxMTQyMiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9"
          };

      // Parse the URL to extract query parameters
      final uri = Uri.parse(url);
      final queryParams = uri.queryParameters;

      log("---- REQUEST LOG START ----");
      log("Request Type: POST");
      log("URL: ${uri.origin}${uri.path}");
      log("Query Params: $queryParams");
      log("Body: ${jsonEncode(body)}");
      log("---- REQUEST LOG END ----");

      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess(response.body);
        }
        return response.body;
      } else {
        String errorMessage = 'Something went wrong.';

        final responseData = jsonDecode(response.body);
        if (responseData['errors'] != null &&
            responseData['errors'] is List &&
            responseData['errors'].isNotEmpty) {
          errorMessage =
              responseData['errors'][0]; //Get the first error message
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        if (onError != null) {
          onError(errorMessage);
        }

        // Optional UI feedback
        if (context != null) {
          _showSnackBar(
            context,
            title: 'Error',
            message: errorMessage,
            icon: Icons.error_outline,
          );
        }

        return null;
      }
    } catch (e) {
      log('POST Request Error: $e');
      if (onError != null) {
        onError(e.toString());
      }

      if (context != null) {
        _showSnackBar(
          context,
          title: 'Error',
          message: "An error occurred. Please try again.",
          icon: Icons.error,
        );
      }

      return null;
    }
  }

  // GET request handler
  static Future<dynamic> getRequest({
    required String url,
    Map<String, String>? headers,
    Function(dynamic response)? onSuccess,
    Function(String error)? onError,
    BuildContext? context,
  }) async {
    try {
      final requestHeaders = headers ??
          {
            "Content-Type": "application/json",
            "Authorization":
                "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2xvZ2luIiwiaWF0IjoxNzM3OTk2NTE4LCJleHAiOjYwMDAxNzM3OTk2NDU4LCJuYmYiOjE3Mzc5OTY1MTgsImp0aSI6IjlhWFhuOFZUWTc1Z3FvamEiLCJzdWIiOjIxMTQyMiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9"
          };

      // Parse the URL to extract query parameters
      final uri = Uri.parse(url);
      final queryParams = uri.queryParameters;

      log("---- REQUEST LOG START ----");
      log("Request Type: GET");
      log("URL: ${uri.origin}${uri.path}");
      log("Query Params: $queryParams");
      log("---- REQUEST LOG END ----");

      final response = await http.get(
        uri,
        headers: requestHeaders,
      );

      log("---- RESPONSE LOG START ----");
      log("Response Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");
      log("---- RESPONSE LOG END ----");

      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess(response.body);
        }
        return response.body;
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Something went wrong.';
        if (onError != null) {
          onError(errorMessage);
        }

        if (context != null) {
          _showSnackBar(
            context,
            title: 'Error',
            message: errorMessage,
            icon: Icons.error_outline,
          );
        }

        return null;
      }
    } catch (e) {
      log('GET Request Error: $e');
      if (onError != null) {
        onError(e.toString());
      }

      if (context != null) {
        _showSnackBar(
          context,
          title: 'Error',
          message: "An error occurred. Please try again.",
          icon: Icons.error,
        );
      }

      return null;
    }
  }

  ApiService.showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      title: 'Error',
      message: message,
      icon: Icons.error_outline,
    );
  }

  // Custom Snackbar
  static void _showSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Detect system brightness (light/dark)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Dynamic colors
    final Color backgroundColor =
        isDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color iconBackgroundColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);
    final Color iconColor = isDarkMode ? Colors.white : Colors.black;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    // Get screen width for responsive sizing
    final double screenWidth = MediaQuery.of(context).size.width;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // 5% padding from sides
          vertical: 10,
        ),
        content: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon wrapper
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Message
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    // Action Button
                    if (actionLabel != null && onAction != null)
                      TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(top: 8),
                        ),
                        child: Text(
                          actionLabel,
                          style: GoogleFonts.montserrat(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
