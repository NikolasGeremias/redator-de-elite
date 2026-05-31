import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get tema {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.verde,
      onPrimary: AppColors.branco,
      primaryContainer: AppColors.verdeEscuro,
      onPrimaryContainer: AppColors.branco,
      secondary: AppColors.azul,
      onSecondary: AppColors.branco,
      secondaryContainer: AppColors.azulEscuro,
      onSecondaryContainer: AppColors.branco,
      tertiary: AppColors.bege,
      onTertiary: AppColors.preto,
      error: AppColors.erro,
      onError: AppColors.branco,
      surface: AppColors.superficie,
      onSurface: AppColors.textoForte,
      surfaceContainerHighest: AppColors.superficieElevada,
      onSurfaceVariant: AppColors.textoSuave,
      outline: AppColors.borda,
      outlineVariant: AppColors.bordaForte,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.preto,
      canvasColor: AppColors.preto,
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: AppColors.textoSuave),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textoForte),
        bodyMedium: TextStyle(color: AppColors.textoSuave),
        bodySmall: TextStyle(color: AppColors.textoApagado),
        titleLarge: TextStyle(color: AppColors.textoForte),
        titleMedium: TextStyle(color: AppColors.textoForte),
        titleSmall: TextStyle(color: AppColors.textoForte),
        labelLarge: TextStyle(color: AppColors.textoForte),
        labelMedium: TextStyle(color: AppColors.textoSuave),
        labelSmall: TextStyle(color: AppColors.textoApagado),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.preto,
        foregroundColor: AppColors.branco,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fonteSubtitulo,
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w700,
          color: AppColors.branco,
        ),
        iconTheme: IconThemeData(color: AppColors.branco),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: AppColors.branco,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: AppTextStyles.botao,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: AppColors.branco,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: AppTextStyles.botao,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textoForte,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.bordaForte),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: AppTextStyles.botao.copyWith(
            color: AppColors.textoForte,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.verdeClaro,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: AppColors.textoSuave),
        hintStyle: const TextStyle(color: AppColors.textoApagado),
        prefixIconColor: AppColors.textoSuave,
        suffixIconColor: AppColors.textoSuave,
        floatingLabelStyle: const TextStyle(color: AppColors.verdeClaro),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.bordaForte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.bordaForte),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.erro),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.erro, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borda),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.pretoSuave,
        elevation: 0,
        scrimColor: Color(0xCC000000),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.pretoSuave,
        selectedItemColor: AppColors.verde,
        unselectedItemColor: AppColors.textoSuave,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.verde,
        linearTrackColor: AppColors.superficieElevada,
        circularTrackColor: AppColors.superficieElevada,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.superficieElevada,
        contentTextStyle: const TextStyle(color: AppColors.branco),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borda,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.bege,
        textColor: AppColors.textoForte,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textoForte,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textoSuave,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.pretoSuave,
        modalBackgroundColor: AppColors.pretoSuave,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.superficie,
        selectedColor: AppColors.verde,
        labelStyle: const TextStyle(color: AppColors.textoSuave),
        secondaryLabelStyle: const TextStyle(color: AppColors.branco),
        side: const BorderSide(color: AppColors.bordaForte),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.superficie,
        headerBackgroundColor: AppColors.pretoSuave,
        headerForegroundColor: AppColors.branco,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.branco;
          return AppColors.textoForte;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.verde;
          return Colors.transparent;
        }),
        todayForegroundColor:
            const WidgetStatePropertyAll(AppColors.verdeClaro),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.branco;
          return AppColors.textoForte;
        }),
      ),
    );
  }
}
