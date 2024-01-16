import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enums.dart';
import 'helpers.dart';
import 'models.dart';

class EpsonEPOS {
  static const MethodChannel _channel = const MethodChannel('epson_epos');

  static EpsonEPOSHelper _eposHelper = EpsonEPOSHelper();

  static bool _isPrinterPlatformSupport({bool throwError = false}) {
    if (Platform.isAndroid) return true;
    if (throwError) {
      throw PlatformException(
          code: "platformNotSupported", message: "Device not supported");
    }
    return false;
  }

  static Future<List<EpsonPrinterModel>?> onDiscovery(
      {EpsonEPOSPortType type = EpsonEPOSPortType.ALL}) async {
    if (!_isPrinterPlatformSupport(throwError: true)) return null;
    String printType = _eposHelper.getPortType(type);
    final Map<String, dynamic> params = {"type": printType};
    String? rep = await _channel.invokeMethod('onDiscovery', params);
    if (rep != null) {
      try {
        final response = EpsonPrinterResponse.fromRawJson(rep);

        List<dynamic>? prs = response.content;
        if (prs == null) {
          return [];
        }
        if (prs.length > 0) {
          return prs.map((e) {
            var printer = EpsonPrinterModel(
              ipAddress: e['ipAddress'],
              bdAddress: e['bdAddress'],
              macAddress: e['macAddress'],
              type: printType,
              model: e['model'],
              // series: modelSeries?.id,
              // series: "TM_M30II",
              series: "TM_M30",
              target: e['target'],
            );
            print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
            print('Printer:');
            print(printer.toJson().toString());
            print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
            return printer;
          }).toList();
        } else {
          return [];
        }
      } catch (e) {
        throw e;
      }
    }
    return [];
  }

  static Future<dynamic> onPrint(
      EpsonPrinterModel printer, List<Map<String, dynamic>> commands) async {
    final Map<String, dynamic> params = {
      "type": printer.type,
      "series": printer.series,
      "commands": commands,
      "target": printer.target
    };
    return await _channel.invokeMethod('onPrint', params);
  }

  static Future<dynamic> disconnectPrinter() async {
    var res = await _channel.invokeMethod('disconnectPrinter');
    return res;
  }

  static Future<dynamic> getPrinterSetting(EpsonPrinterModel printer) async {
    final Map<String, dynamic> params = {
      "type": printer.type,
      "series": printer.series,
      "target": printer.target
    };
    return await _channel.invokeMethod('getPrinterSetting', params);
  }

  static Future<dynamic> setPrinterSetting(EpsonPrinterModel printer,
      {int? paperWidth, int? printDensity, int? printSpeed}) async {
    final Map<String, dynamic> params = {
      "type": printer.type,
      "series": printer.series,
      "paper_width": paperWidth,
      "print_density": printDensity,
      "print_speed": printSpeed,
      "target": printer.target
    };
    return await _channel.invokeMethod('setPrinterSetting', params);
  }
}
