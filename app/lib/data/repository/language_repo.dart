import 'package:flutter/material.dart';
import 'package:flutter_pdg/data/model/response/language_model.dart';
import 'package:flutter_pdg/utill/app_constants.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({BuildContext context}) {
    return AppConstants.languages;
  }
}
