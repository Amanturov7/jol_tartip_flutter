import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Функция для сжатия изображения
Future<File> compressImage(File file) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);

  // Resize and compress the image
  final resizedImage = img.copyResize(image!, width: 800); // Измените размер по необходимости
  final compressedBytes = img.encodeJpg(resizedImage, quality: 70); // Качество от 0 до 100

  // Save the compressed image
  final compressedFile = File('${file.path}_compressed.jpg');
  await compressedFile.writeAsBytes(compressedBytes);

  return compressedFile;
}
