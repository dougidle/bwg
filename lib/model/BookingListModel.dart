import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../model/summary.dart';
import '../resources/bwg_colors.dart';

class BookingListModel {
  Future<Summary> getRandomArticleSummary() async {
    final uri = Uri.https(
      'en.wikipedia.org',
      '/api/rest_v1/page/random/summary',
    );
    final response = await get(uri);

    if (response.statusCode != 200) {
      throw HttpException('Failed to update resource');
    }

    return Summary.fromJson(jsonDecode(response.body));
  }
}
